#!/usr/bin/env python3

import json
import subprocess
import argparse
import sys
import os


class TerraformInventory:
    def __init__(self):
        self.inventory = {
            "_meta": {"hostvars": {}},
            "all": {
                "hosts": [],
            },
        }
    
    def add_host(self, hostname, ip, extra_vars=None):
        """Add a host to the inventory"""
        self.inventory["all"]["hosts"].append(hostname)

        host_vars = {
            "ansible_host": ip,
            "ansible_python_interpreter": "/usr/bin/python3",
            "ansible_connection": "ssh",
        }

        # Add any extra variables from Terraform outputs
        if extra_vars:
            for key, value in extra_vars.items():
                host_vars[f"{key}"] = value

        self.inventory["_meta"]["hostvars"][hostname] = host_vars


def get_terraform_outputs(terraform_dir):
    """Get Terraform outputs as JSON"""
    try:
        result = []
        # Change to terraform directory
        original_dir = os.getcwd()
        os.chdir(terraform_dir)
        for dr in os.listdir(terraform_dir):
            if os.path.isdir(dr):
                os.chdir(dr)
                result.append(
                    json.loads(
                        subprocess.run(
                            ["tofu", "output", "-json"],
                            capture_output=True,
                            text=True,
                            check=True,
                        ).stdout
                    )
                )

        # Run terraform output -json
        os.chdir(original_dir)
        return result

    except subprocess.CalledProcessError as e:
        print(f"Error running terraform output: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing terraform output JSON: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error getting terraform outputs: {e}", file=sys.stderr)
        sys.exit(1)


def is_valid_ip(ip):
    """Basic IP address validation"""
    try:
        parts = ip.split(".")
        return len(parts) == 4 and all(0 <= int(part) <= 255 for part in parts)
    except (ValueError, AttributeError):
        return False


def get_inventory(terraform_dir):
    inventory = TerraformInventory()
    """Build Ansible inventory from Terraform outputs"""
    outputs = get_terraform_outputs(terraform_dir)
    hosts_added = False
    for output in outputs:
        ip = output["public_ip"]["value"]
        hostname = output["hostname"]["value"]
        ssh_private_key_file = output["ssh_private_key_file"]["value"]
        ssh_user = output["ssh_user"]["value"]
        if isinstance(ip, list):
            for i, ip in enumerate(value):
                if isinstance(ip, str) and is_valid_ip(ip):
                    # Create hostname based on output name and index
                    inventory.add_host(
                        hostname,
                        ip,
                        {
                            "ansible_ssh_private_key_file": terraform_dir
                            + ssh_private_key_file
                        },
                    )
                    hosts_added = True
        if isinstance(ip, str) and is_valid_ip(ip):
            inventory.add_host(
                hostname,
                ip,
                {
                    "ansible_ssh_private_key_file": terraform_dir
                    + ssh_private_key_file,
                    "ansible_user": ssh_user,
                },
            )
            hosts_added = True

    if not hosts_added:
        print(
            "Warning: No IP address outputs found in Terraform state", file=sys.stderr
        )
        print("Available outputs:", list(outputs.keys()), file=sys.stderr)

    return inventory.inventory


def main():
    parser = argparse.ArgumentParser(
        description="Ansible dynamic inventory from Terraform outputs"
    )
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--list", action="store_true", help="List all hosts")
    group.add_argument("--host", help="Get variables for a specific host")
    parser.add_argument(
        "--terraform-dir",
        default="../terraform/",
        help="Path to Terraform directory (default: current directory)",
    )
    args = parser.parse_args()

    inventory = get_inventory(args.terraform_dir)
    if args.list:
        return json.dumps(inventory)
    elif args.host:
        host_vars = inventory["_meta"]["hostvars"].get(host, {})
        return json.dumps(host_vars)


if __name__ == "__main__":
    print(main())
