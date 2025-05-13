import requests
import random
import json
from PIL import Image
from io import BytesIO
import base64
import time


class GSTPortalClient:
    def __init__(self):
        self.base_url = "https://services.gst.gov.in"
        self.search_page_url = f"{self.base_url}/services/searchtpbypan"
        self.captcha_url = f"{self.base_url}/services/captcha"
        self.api_url = f"{self.base_url}/services/api/get/gstndtls"
        self.session = requests.Session()
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:138.0) Gecko/20100101 Firefox/138.0",
            "Accept-Language": "en-US,en;q=0.5",
            "Accept-Encoding": "gzip, deflate, br, zstd",
            "DNT": "1",
            "Connection": "keep-alive",
        }
        self.captcha_cookie = None
        self.captcha_image = None

    def initialize_session(self):
        """Visit the main page to initialize cookies"""
        self.headers["Accept"] = (
            "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8"
        )
        self.headers["Referer"] = "https://services.gst.gov.in/"
        response = self.session.get(self.search_page_url, headers=self.headers)
        if response.status_code != 200:
            raise Exception(
                f"Failed to initialize session. Status code: {response.status_code}"
            )
        return True

    def get_captcha(self):
        """Fetch the captcha image and associated cookie"""
        # Add a random parameter to prevent caching
        random_param = random.random()
        captcha_url_with_param = f"{self.captcha_url}?rnd={random_param}"

        self.headers["Accept"] = (
            "image/avif,image/jxl,image/webp,image/png,image/svg+xml,image/*;q=0.8,*/*;q=0.5"
        )
        self.headers["Referer"] = self.search_page_url

        response = self.session.get(captcha_url_with_param, headers=self.headers)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get captcha. Status code: {response.status_code}"
            )

        # Get the captcha cookie
        for cookie in self.session.cookies:
            if cookie.name == "CaptchaCookie":
                self.captcha_cookie = cookie.value
                break

        # Store the captcha image
        self.captcha_image = Image.open(BytesIO(response.content))

        # Return both the image and the cookie
        return {"image": self.captcha_image, "cookie": self.captcha_cookie}

    def save_captcha_image(self, filename="captcha.png"):
        """Save the captcha image to a file"""
        if self.captcha_image:
            self.captcha_image.save(filename)
            return True
        return False

    def get_captcha_as_base64(self):
        """Convert the captcha image to base64 for displaying in UI"""
        if self.captcha_image:
            buffered = BytesIO()
            self.captcha_image.save(buffered, format="PNG")
            img_str = base64.b64encode(buffered.getvalue()).decode()
            return img_str
        return None

    def query_gst_details(self, pan_number, captcha_solution):
        """Submit the PAN and captcha to get GST details"""
        payload = {"panNO": pan_number, "captcha": captcha_solution}

        self.headers["Accept"] = "application/json, text/plain, */*"
        self.headers["Content-Type"] = "application/json;charset=utf-8"
        self.headers["Origin"] = self.base_url
        self.headers["Referer"] = self.search_page_url

        response = self.session.post(self.api_url, headers=self.headers, json=payload)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get GST details. Status code: {response.status_code}"
            )

        return response.json()

    def get_taxpayer_details(self, gstin, captcha_solution):
        """Get detailed taxpayer information using GSTIN and captcha"""
        url = f"{self.base_url}/services/api/search/taxpayerDetails"

        payload = {"gstin": gstin, "captcha": captcha_solution}

        self.headers["Accept"] = "application/json, text/plain, */*"
        self.headers["Content-Type"] = "application/json;charset=utf-8"
        self.headers["Origin"] = self.base_url
        self.headers["Referer"] = f"{self.base_url}/services/searchtp"

        response = self.session.post(url, headers=self.headers, json=payload)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get taxpayer details. Status code: {response.status_code}"
            )

        return response.json()

    def get_goods_services(self, gstin):
        """Get goods and services information for the GSTIN"""
        url = f"{self.base_url}/services/api/search/goodservice?gstin={gstin}"

        self.headers["Accept"] = "application/json, text/plain, */*"
        self.headers["Referer"] = f"{self.base_url}/services/searchtp"

        response = self.session.get(url, headers=self.headers)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get goods and services information. Status code: {response.status_code}"
            )

        return response.json()

    def get_financial_years(self, gstin):
        """Get list of available financial years for the GSTIN"""
        url = f"{self.base_url}/services/api/dropdownfinyear?gstin={gstin}"

        self.headers["Accept"] = "application/json, text/plain, */*"
        self.headers["Referer"] = f"{self.base_url}/services/searchtp"

        response = self.session.get(url, headers=self.headers)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get financial years. Status code: {response.status_code}"
            )

        return response.json()

    def get_return_details(self, gstin, fy):
        """Get return filing details for the GSTIN for a specific financial year"""
        url = f"{self.base_url}/services/api/search/taxpayerReturnDetails"

        payload = {"gstin": gstin, "fy": fy}

        self.headers["Accept"] = "application/json, text/plain, */*"
        self.headers["Content-Type"] = "application/json;charset=utf-8"
        self.headers["Origin"] = self.base_url
        self.headers["Referer"] = f"{self.base_url}/services/searchtp"

        response = self.session.post(url, headers=self.headers, json=payload)

        if response.status_code != 200:
            raise Exception(
                f"Failed to get return details. Status code: {response.status_code}"
            )

        return response.json()

    def complete_pan_workflow(self, pan_number, captcha_solver_func=None):
        """Complete the entire workflow to fetch GST details

        Args:
            pan_number: The PAN number to query
            captcha_solver_func: A function that will solve the captcha. If None, will prompt user for input.

        Returns:
            The GST details JSON response
        """
        self.initialize_session()

        captcha_info = self.get_captcha()

        if captcha_solver_func:
            captcha_solution = captcha_solver_func(self.captcha_image)
        else:
            self.save_captcha_image()
            print("Captcha image saved as 'captcha.png'")
            captcha_solution = input("Please enter the captcha solution: ")

        result = self.query_gst_details(pan_number, captcha_solution)

        return result

    def fetch_complete_gst_data(self, gstin, captcha_solver_func=None):
        """Fetch all available GST data for a given GSTIN

        Args:
            gstin: The GSTIN to query
            captcha_solver_func: A function that will solve the captcha. If None, will prompt user for input.

        Returns:
            Dictionary with all GST data
        """
        # Step 1: Get comprehensive taxpayer details (requires captcha)
        self.initialize_session()
        captcha_info = self.get_captcha()

        if captcha_solver_func:
            captcha_solution = captcha_solver_func(self.captcha_image)
        else:
            self.save_captcha_image()
            print("Captcha image saved as 'captcha.png'")
            captcha_solution = input("Please enter the captcha solution: ")

        taxpayer_details = self.get_taxpayer_details(gstin, captcha_solution)

        # Step 2: Get goods and services information (no captcha required)
        goods_services = self.get_goods_services(gstin)

        # Step 3: Get list of available financial years
        financial_years = self.get_financial_years(gstin)

        # Step 4: Get return filing details for each available year
        return_details = {}
        if financial_years.get("status") == 1:
            for year_info in financial_years.get("data", []):
                year_value = year_info.get("value")
                return_details[year_value] = self.get_return_details(gstin, year_value)

        # Combine all data
        complete_data = {
            "taxpayer_details": taxpayer_details,
            "goods_services": goods_services,
            "financial_years": financial_years,
            "return_details": return_details,
        }

        return complete_data


def main():
    gst_client = GSTPortalClient()

    try:
        # Step 1: Get GSTIN from PAN
        pan_number = "AABFS0153K"
        print(f"Looking up GSTIN for PAN: {pan_number}")

        pan_result = gst_client.complete_pan_workflow(pan_number)

        gstin = None
        gstin_res_list = pan_result.get("gstinResList", [])
        if gstin_res_list:
            gstin = gstin_res_list[0].get("gstin")
            gstin_authstatus = gstin_res_list[0].get("authStatus")
            gstin_stateCd = gstin_res_list[0].get("stateCd")
            print(
                f"GSTIN found: {gstin}, Auth Status: {gstin_authstatus}, State Code: {gstin_stateCd}"
            )
        else:
            print("No GSTIN details found.")
            return

        # Step 2: Get complete GST data for the found GSTIN
        print(f"\nFetching complete GST data for GSTIN: {gstin}")
        complete_data = gst_client.fetch_complete_gst_data(gstin)

        # Output the data
        print("\n=== Taxpayer Details ===")
        print(f"Legal Name: {complete_data['taxpayer_details'].get('lgnm')}")
        print(f"Trade Name: {complete_data['taxpayer_details'].get('tradeNam')}")
        print(f"Status: {complete_data['taxpayer_details'].get('sts')}")
        print(
            f"Constitution of Business: {complete_data['taxpayer_details'].get('ctb')}"
        )
        print(f"Registration Date: {complete_data['taxpayer_details'].get('rgdt')}")

        # Address
        address = complete_data["taxpayer_details"].get("pradr", {}).get("adr", "N/A")
        print(f"Address: {address}")

        print("\n=== Goods and Services ===")
        for item in complete_data["goods_services"].get("bzgddtls", []):
            print(f"HSN Code: {item.get('hsncd')} - {item.get('gdes')}")

        print("\n=== Return Filing Details ===")
        for year, details in complete_data["return_details"].items():
            print(f"\nFinancial Year: {year}")
            filing_status = details.get("filingStatus", [[]])
            if filing_status and filing_status[0]:
                for return_entry in filing_status[0]:
                    print(
                        f"Period: {return_entry.get('taxp')} {return_entry.get('fy')}, "
                        f"Type: {return_entry.get('rtntype')}, "
                        f"Status: {return_entry.get('status')}, "
                        f"Filed on: {return_entry.get('dof')}"
                    )
            else:
                print("No return filing data available")

        # Save the complete data to a file for reference
        with open(f"{gstin}_complete_data.json", "w") as f:
            json.dump(complete_data, f, indent=2)

        print(f"\nComplete data saved to {gstin}_complete_data.json")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()
