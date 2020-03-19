. settings
n=1
servertemplate='./tpl/servertemplate'
peertemplate='./tpl/peertemplate'
peersectiontemplate='./tpl/peersectiontemplate'

[ ! -d ${output} ] && mkdir ${output}

#
# server
#
private_key=$(wg genkey)
public_key=$(echo $private_key | wg pubkey)
preshared_key=$(wg genkey)
echo "Server public key:  $public_key"
[ ! -d ${output}/${server} ] && mkdir ${output}/${server}

echo ${private_key} > ${output}/${server}/private
echo ${public_key} > ${output}/${server}/public
server_public_key=${public_key}
echo > ${output}/${server}/${server}.conf
serverip=${vpnip}${n} private_key=${private_key} port=${port} envsubst < ${servertemplate} >> ${output}/${server}/${server}.conf

#peers
while read line; do
  i=$line
  n=$((n+1))
  private_key=$(wg genkey)
  public_key=$(echo $private_key | wg pubkey)
  preshared_key=$(wg genkey)
  echo "Peer $i public key:  $public_key"
  [ ! -d ${output}/${i} ] && mkdir ${output}/${i}
  echo ${private_key} > ${output}/${i}/private
  echo ${public_key} > ${output}/${i}/public
  echo ${preshared_key} > ${output}/${i}/preshared
  peerip=${vpnip}${n} peer=${i} public_key=${public_key} preshared_key=${preshared_key} localnet=${localnet} \
    envsubst < ${peersectiontemplate} >> ${output}/${server}/${server}.conf
  peerip=${vpnip}${n} peer=${i} server_public_key=${server_public_key} preshared_key=${preshared_key} localnet=${localnet} private_key=${private_key}\
  endpoint=${endpoint} port=${port}  envsubst < ${peertemplate} > ${output}/${i}/${i}.conf
  qrencode -t ansiutf8 < ${output}/${i}/${i}.conf > ${output}/${i}/${i}.qrcode
  qrencode -o  ${output}/${i}/${i}.png < ${output}/${i}/${i}.conf
done < $peers
