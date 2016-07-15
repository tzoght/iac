# Installs a VMR on Vagrant VM or a docker-machine


## Must have
* Assumes you have a access to a VMR docker distribution
* Vagrant 1.8.1 and above
* VirtualBox 5.0.2 and above
* You have installed docker and docker-machine (version 1.11.2 and above)

## To run it in Vagrant
1. Clone this repo `git clone https://github.com/tzoght/iac.git`
2. Go to `cd ./iac/vmr/vagrant-vmr` and:
3. Edit `config.yml` to point to the VMR image and label `vmr.docker.image` and
  `vmr.docker.label`
4. then run `vagrant up`
5. ssh to the cli `ssh admin@my-vmr-host -p 32`

## To run it as a docker-machine
1. Clone this repo `git clone https://github.com/tzoght/iac.git`
2. Go to `cd ./iac/vmr/vagrant-vmr` and:
3. run `./install_vmr.sh -d <vmr image>  -l <vmr label> -c`
5. ssh to the cli `ssh admin@$(docker-machine ip vmr)`
