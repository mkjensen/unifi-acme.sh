# unifi-acme.sh

The `update-unifi-certificate.sh` script enables easy updating of the certificate used by [UniFi Controller](https://www.ubnt.com/enterprise/software). The script has been tested on Debian 8 "Jessie" with Unifi Controller installed via the official Debian repository and on a UniFi CloudKey on firmware version 0.7.3.

## How to use

* Install [acme.sh](https://github.com/Neilpang/acme.sh) and follow the instructions to create a certificate for the domain you want to use to access UniFi Controller.
* Set the reload command to the `update-unifi-certificate.sh` script:
  * `--reloadcmd '/path/to/update-unifi-certificate.sh "certificate.domain.here" "/path/to/certificate/directory"'`
* If acme.sh was installed in the default directory (`.acme.sh` in the user's home directory) and the certificate directory is under `.acme.sh` and is named for the domain inside of it, the second parameter can be omitted from the command:
  * `--reloadcmd '/path/to/update-unifi-certificate.sh "certificate.domain.here"'`

## License

Copyright 2016 Martin Kamp Jensen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
