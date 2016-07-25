#!/bin/bash
MINPARAMS=4
echo "running script  \"`basename $0`\" with \"$*\"  "


createMachine ()
{
   docker-machine create -d virtualbox --virtualbox-memory "5000" --virtualbox-cpu-count "4"  \
    --engine-opt="label=com.function=consul"  vmr
   docker-machine start vmr
   eval $(docker-machine env vmr)
}

runVMRDockerContainer ()
{
  docker load --input $1
  docker run -d --privileged -v jail:/usr/sw/jail -v var:/usr/sw/var \
  -v internalSpool:/usr/sw/internalSpool -v adbBackup:/usr/sw/adb \
  -v adb:/usr/sw/internalSpool/softAdb -v /dev/shm:/dev/shm \
  -v `pwd`/sshd_config:/etc/ssh/sshd_config \
  --name vmr \
  --net=host --uts=host -P --env NODE_TYPE=MESSAGE_ROUTER_NODE_TYPE\
  $2

}

configureVMR ()
{
  #echo -e "admin" | docker exec -i $(docker ps -q) passwd admin --stdin
  #echo -e "support" | docker exec -i $(docker ps -q) passwd support --stdin
  echo -e "admin" | docker exec -i vmr passwd admin --stdin
  echo -e "support" | docker exec -i vmr passwd support --stdin
  sleep 15
  docker exec -i vmr /bin/bash -c "/usr/sbin/service solace stop; /usr/sw/loads/currentload/scripts/persistutils -d;/usr/sbin/service solace start"
}

print_help ()
{
  echo
  echo "This script needs at least $MINPARAMS command-line arguments!"
  echo "$0 -d <vmr docker image tar> -l <vmr docker image label> [-c] [-h]"
  echo "where:"
  echo "   -d: vmr docker image tar file, example: soltr-7.2.0.603-vmr-enterprise-docker.tar.gz"
  echo "   -l: vmr docker image label, example: solace-app:7.2.0.603-enterprise"
  echo "   -h: prints this help message"
  echo "   -c: creates a docker-machine"
  exit -1
}

if [ $# -lt "$MINPARAMS" ]
then
  print_help
fi

# Initialize our own variables:
_create_docker_machine="no"
_vmr_docker_image=""
_vmr_label=""
_print_help="no"

while true; do
  case "$1" in
    -h | --help ) _print_help="yes"; shift ;;
    -c | --create_docker_machine )   _create_docker_machine="yes"; shift ;;
    -d | --vmr-docker-image ) _vmr_docker_image="$2"; shift; shift ;;
    -l | --vmr-label) _vmr_label="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ $_print_help = "yes" ]; then
  print_help
  exit 0
fi

echo "Excecuting: "
if [ $_create_docker_machine = "yes" ]; then
   echo "createing a docker machine"
   createMachine
fi
runVMRDockerContainer $_vmr_docker_image $_vmr_label
sleep 20
configureVMR
exit 0


# To cleanup
# docker rmi -f $(docker images -q)
# docker rm -f $(docker ps -a -q)
