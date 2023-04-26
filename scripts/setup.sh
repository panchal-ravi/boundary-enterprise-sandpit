DATETIME=$(date +'%d%m%Y_%H%M%S')
TFDIR=$1
if [ ! -d "$TFDIR/generated" ]; then
  mkdir $TFDIR/generated
fi

cp $TFDIR/generated/global_auth_method_id $TFDIR/generated/global_auth_method_id_$DATETIME 
echo '' > $TFDIR/generated/global_auth_method_id 
cp $TFDIR/generated/ingress_worker_auth_token $TFDIR/generated/ingress_worker_auth_token_$DATETIME 
echo '' > $TFDIR/generated/ingress_worker_auth_token 
cp $TFDIR/generated/egress_worker_auth_token $TFDIR/generated/egress_worker_auth_token_$DATETIME 
echo '' > $TFDIR/generated/egress_worker_auth_token 
cp $TFDIR/generated/kms_recovery.hcl $TFDIR/generated/kms_recovery_$DATETIME.hcl 
echo '' > $TFDIR/generated/kms_recovery.hcl 
cp $TFDIR/generated/vault_token  $TFDIR/generated/vault_token_$DATETIME 
echo '' > $TFDIR/generated/vault_token
cp $TFDIR/generated/boundary_password  $TFDIR/generated/boundary_password_$DATETIME 
echo '' > $TFDIR/generated/boundary_password  
cp $TFDIR/generated/ssh_key $TFDIR/generated/ssh_key_$DATETIME 
echo '' > $TFDIR/generated/ssh_key
cp $TFDIR/generated/vault_credstore_id $TFDIR/generated/vault_credstore_id_$DATETIME 
echo '' > $TFDIR/generated/vault_credstore_id
cp $TFDIR/generated/rsa_key $TFDIR//generated/rsa__$DATETIME 
echo '' > $TFDIR//generated/rsa_key
cp $TFDIR//generated/k8s_auth_request_token $TFDIR//generated/k8s_auth_request_token_$DATETIME 
echo '' > $TFDIR//generated/k8s_auth_request_token


# cp ./generated/worker_egress_auth_request_token ./generated/worker_egress_auth_request_token_$DATETIME 
# echo '' > ./generated/worker_egress_auth_request_token
# cp ./generated/boundary_token ./generated/boundary_token_$DATETIME 
# echo '' > ./generated/boundary_token
# cp $TFDIR/generated/boundary_cluster_id $TFDIR/generated/boundary_cluster_id_$DATETIME 
# echo '' > $TFDIR/generated/boundary_cluster_id 

