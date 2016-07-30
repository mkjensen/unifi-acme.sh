# unifi-acme.sh

The `update-unifi-certificate.sh` script enables easy updating of the certificate used by the [UniFi Controller](https://www.ubnt.com/enterprise/software).

## How to use

* Install [acme.sh](https://github.com/Neilpang/acme.sh) and follow the instructions to create a certificate for the domain you want to use to access the UniFi controller.
* Update the `update-unifi-certificate.sh` script:
  * Set the `DOMAIN` variable to the domain for which you previously generated a certificate using acme.sh.
  * Set the `ACME_SH` variable to the location of the `acme.sh` installation.
* Execute `update-unifi-certificate.sh` to update the Unifi Controller.

## TODO

The `update-unifi-certificate.sh` script should be run automatically whenever a new certificate is generated via `acme.sh`. For now, you must manually execute `update-unifi-certificate.sh`.
