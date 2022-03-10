Here you can find a bash scripts in 3 configurations that will perform the deployment of the Spring Petclinic application on virtual machines in the Google Cloud Platform infrastructure with an Angular frontend and a mysql database. 

## Configurations

# Configuration 1

![image](https://user-images.githubusercontent.com/82798907/157537539-a326c90a-15e6-4830-83d0-15a35f71d8cf.png)

# Configuration 2

![image](https://user-images.githubusercontent.com/82798907/157537653-414aab01-a090-4ad7-b7b0-12f9a84a200c.png)

# Configuration 3

![image](https://user-images.githubusercontent.com/82798907/157537712-55e0e9bc-33d2-49fa-90a0-d05d11a37791.png)

## Usage
Before using the script, make sure you have the gcloud (CLoud SDK) package installed. [Installation instructions] (https://cloud.google.com/sdk/docs/install)

There are two possible ways to run ** SpringPetclinicDeploy.sh **. 

### Method # 1 - direct script usage
1. We create virtual machines on our own in Google Compute Engine. They must meet the following conditions:
    * Machine: e2-highcpu-4 (backend) /
    * Boot disk size: 20GB
    * System: Ubuntu 20.04 LTS
    * Firewall rules: HTTP and HTTPS traffic allowed
    * API: 'Allow full access to all Cloud APIs'
    * We give each machine a unique name and leave the other parameters unchanged
    
    For configuration 1 we need:
    * 1 machine - all components on one machine;
    * 2 machines - any two components on one machine and one on a separate machine;
    * 3 machines - database, backend, frontend.

    For configurations 2 and 3 we need:
    * 4 machines - master base, slave base, 2 backends on one machine, load balancer and frontend on one machine;
    * 5 machines - master base, slave base, backend 1, backend 2, load balancer and frontend on one machine;
    * 5 machines - master base, slave base, 2 backends on one machine, load balancer, frontend;
    * 6 machines - each component separately.

2. We give the script executable permissions: 
   ```bash
    $ chmod a+x script.sh
    ```

3. We run the script as follows:      
     * For configuration 1: 
     ```bash
    $ ./script.sh --config=1 --project=PROJECT_ID --frontend=FRONTEND --backend=BACKEND [--backend-port=BACKEND_PORT;default=9966] --database=DATABASE [| tee log.out]
    ```
    By substituting in the above:
     * PROJECT_ID - Google Cloud Platform project ID
     * FRONTEND - name of the machine on which the frontend will be put
     * BACKEND - the name of the machine on which the backend will be placed
     * BACKEND_PORT - port on which the backend will run
     * DATABASE - the name of the machine on which the database will be placed
    
     ** ATTENTION ** We can specify the same machine for all components or combine two of them freely and specify a different one for the third. 
     
     * For configurations 2 and 3:
    `` bash
    ./script.sh --config = 4 | 5 --project = PROJECT_ID --frontend = FRONTEND --backend1 = BACKEND1 [--backend1-port = BACKEND1_PORT; default = 9966] --backend2 = BACKEND2 [--backend2- port = BACKEND2_PORT; default = 9966] [--nginx = NGINX; default = FRONTEND] --master = MASTER --slave = SLAVE [| tee log.out]
    ``
    By substituting in the above:
    * PROJECT_ID - Google Cloud Platform project ID
    * FRONTEND - name of the machine on which the frontend will be put
    * BACKEND1 - name of the machine on which one backend will be placed
    * BACKEND2 - name of the machine where the second backend will be placed
    * BACKEND1_PORT - port on which one backend will run
    * BACKEND2_PORT - port on which the second backend will run
    * NGINX - the name of the machine on which the load balancer will be placed (if not given, the load balancer is placed on the machine with the frontend)
    * MASTER - the name of the machine on which the master database will be placed
    * SLAVE - the name of the machine on which the slave database will be placed

    ** NOTE ** We can provide the same machine for:
    * FRONTEND and NGINX
    * BACKEND1 and BACKEND2 (** Then BACKEND1_PORT and BACKEND2_PORT must be different **)

### Method # 2 - using the helper vm.sh script that automates the management of virtual machines
1. All parameters must be completed in the script (most of them have already been given values). The most important are PROJECT_ID (Google Cloud Platform project ID) and CONFIG (configuration to be done, possible values: 1, 4 or 5).

    ** ATTENTION ** Please make sure that the given names of virtual machines (lines in script 15-25) do not conflict with machines already owned by Google Compute Engine. If it turns out that we already have a machine with the name used in the script ** IT WILL BE DELETED **. Therefore, in such a case, this name should be changed to whatever you choose, not colliding with any of your machines.

    ** NOTE 2 ** The same goes for template names (lines 29-30). You should also make sure that you do not have templates with the given names.

2. We give the scripts executable permissions:
    `` bash
    $ chmod a + x vm.sh
    $ chmod a + x script.sh
    ``

3. We run the script:
    `` bash
    $ ./vm.sh
    ``
    ** ATTENTION ** The script protects against unnecessary use of machines. By default, after starting the application, the script will wait 20 minutes and then stop all instances it is using. You can change this time by changing the value of the TTL variable (line 80 vm.sh) by specifying the time in seconds or you can completely get rid of this functionality by removing the last 3 lines of vm.sh.
    Additionally, you can terminate the script at any time by pressing CTRL + C. After that, the script will turn off the instances (if they were enabled). 
