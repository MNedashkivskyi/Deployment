Here you can find a scripts in Ansible in 3 configurations that will perform the deployment of the Spring Petclinic application on virtual machines in the Google Cloud Platform infrastructure with an Angular frontend and a mysql database.

## Configurations

# Configuration 1

![image](https://user-images.githubusercontent.com/82798907/157537539-a326c90a-15e6-4830-83d0-15a35f71d8cf.png)

# Configuration 2

![image](https://user-images.githubusercontent.com/82798907/157537653-414aab01-a090-4ad7-b7b0-12f9a84a200c.png)

# Configuration 3

![image](https://user-images.githubusercontent.com/82798907/157537712-55e0e9bc-33d2-49fa-90a0-d05d11a37791.png)

## Usage
1. We have created the gcp.yml script which creates machines with names written in the file machines.
Under \ [machines \] we write the names of the machines we want to create. Default configurations (each component
separately), are in the file machines as a formula:
    ``` bash
    # default version for 1 configuration
    [machines]
    database
    backend
    frontend
    ```

    ``` bash
    # default version for 4 & 5 configuration
    [machines]
    master
    slave
    backend1
    backend2
    frontend
    ```

    To run a script for creating machines:
    * Follow the instructions in [gcp ansible documentation] (https://docs.ansible.com/ansible/latest/scenario_guides/guide_gce.html)
    * download the json file with credentials according to [instructions how to download the file for authentication] (https://support.google.com/cloud/answer/6158849?hl=en&ref_topic=6262490#serviceaccounts&zippy=%2Cservice-accounts)
    * paste the downloaded json file to the main project folder
    * fill in the \ <PROJECT NAME \> and \ <GCP CRED FILE \> fields in the gcp.yml file with the project name and the name of the downloaded json file, respectively

    Then you can run the script:
    `` bash
    ansible-playbook -i machines gcp.yml
    ``

    For configuration 1 we need:
    * 1 machine - all components on one machine;
    * 2 machines - any two components on one machine and one on a separate machine;
    * 3 machines - database, backend, frontend (everything separately).

    For configurations 4 and 5 we need:
    * 2 machines - there must be a master base, a slave base, the rest of the components on any;
    * 3 machines - there must be a master base, a slave base, the rest of the components on any;
    * 4 machines - there must be a master base, a slave base, the rest of the components on any;
    * 5 machines - master base, slave base, backend 1, backend 2, frontend (everything separately);

    Alternatively, you can create virtual machines manually in Google Compute Engine. They must meet the following conditions:
    * Machine: e2-highcpu-4 (backend)
    * Boot disk size: 20GB
    * System: Ubuntu 20.04 LTS
    * Firewall rules: HTTP and HTTPS traffic allowed
    * API: 'Allow full access to all Cloud APIs'
    * We give each machine a unique name and leave the other parameters unchanged

2. The script.sh script creates the appropriate playbook based on the machine names and runs the ansible file with the given configuration. We give the script executable permissions:
    `` bash
    $ chmod a + x script.sh
    ``
3. Run the script as follows (the appropriate playbook will be started automatically):
    * For configuration 1:
    `` bash
    $ ./script.sh --config = 1 --project = PROJECT_ID --frontend = FRONTEND --backend = BACKEND [--backend-port = BACKEND_PORT; default = 9966] --database = DATABASE
    ``
    By substituting in the above:
    * PROJECT_ID - Google Cloud Platform project ID
    * FRONTEND - name of the machine on which the frontend will be put
    * BACKEND - the name of the machine on which the backend will be placed
    * BACKEND_PORT - port on which the backend will run
    * DATABASE - the name of the machine on which the database will be placed
    
    ** ATTENTION ** We can specify the same machine for all components or combine two of them freely and specify a different one for the third.

    * For configurations 4 and 5:
    `` bash
    ./script.sh --config = 4 | 5 --project = PROJECT_ID --frontend = FRONTEND --backend1 = BACKEND1 [--backend1-port = BACKEND1_PORT; default = 9966] --backend2 = BACKEND2 [--backend2- port = BACKEND2_PORT; default = 9966] --master = MASTER --slave = SLAVE
    ``
    By substituting in the above:
    * PROJECT_ID - Google Cloud Platform project ID
    * FRONTEND - name of the machine on which the frontend will be put
    * BACKEND1 - name of the machine on which one backend will be placed
    * BACKEND2 - name of the machine where the second backend will be placed
    * BACKEND1_PORT - port on which one backend will run
    * BACKEND2_PORT - port on which the second backend will run
    * MASTER - the name of the machine on which the master database will be placed
    * SLAVE - the name of the machine on which the slave database will be placed

    ** NOTE ** We can provide the same machine for:
    * BACKEND1 and BACKEND2 (** Then BACKEND1_PORT and BACKEND2_PORT must be different **) 
