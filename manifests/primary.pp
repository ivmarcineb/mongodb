#
# Define mongodb::primary
#
define mongodb::primary(
  $username   = undef,
  $password   = undef, 
  $hostname   = "localhost:27017",
  $replicaset = "rs0"
) {
  
  $replica_init_cmd="result=rs.initiate({\"_id\":\"${replicaset}\", \"version\":1, \"members\": [{\"_id\":0, \"host\":\"${hostname}\"}]}); if (result.ok == 1 || result.errmsg == \"already initialized\"){ \"SUCCESS\"}"
  $noauth = "mongo admin --eval '${replica_init_cmd}' | grep SUCCESS -q"
  $auth = "if [ $? -eq 1 ]; then mongo admin -u ${username} -p ${password} --eval '${replica_init_cmd}' | grep SUCCESS -q;fi"
  $command = "${noauth};${auth}"
  exec { "iniatilize_replica" :
    command   => $command,
    path      => "/usr/bin:/usr/sbin:/bin:/sbin",
    logoutput => true,
  }
}
