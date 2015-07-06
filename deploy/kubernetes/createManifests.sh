#! /bin/bash
. ./config/release.cfg
BUILD_NUMBER=$2

versiontag=$servicemajor.$serviceminor.$BUILD_NUMBER
manifestsPath="./deploy/kubernetes"

# RC
rcfile=$manifestsPath/$servicename\_$versiontag\_rc.$template_extension
rcname=$servicename

sed "s/__rcName__/$rcname/g" \
    $manifestsPath/$k8s_api_version/rc.template.$template_extension > $rcfile
sed -i "s/__major__/$servicemajor/g" $rcfile
sed -i "s/__minor__/$serviceminor/g" $rcfile
sed -i "s/__build__/$BUILD_NUMBER/g" $rcfile
sed -i "s|__image__|$1|g" $rcfile
sed -i "s/__privatePortName__/$serviceportname/g" $rcfile
sed -i "s/__privatePort__/$serviceport/g" $rcfile
sed -i "s/__replicas__/1/g" $rcfile


# SERVICE
servicefile=$manifestsPath/$servicename\_$versiontag\_service.$template_extension
sed "s/__serviceName__/$servicename/g" \
    $manifestsPath/$k8s_api_version/service.template.$template_extension > $servicefile
sed -i "s/__major__/$servicemajor/g" $servicefile
sed -i "s/__minor__/$serviceminor/g" $servicefile
sed -i "s/__build__/$BUILD_NUMBER/g" $servicefile
sed -i "s/__privatePortName__/$serviceportname/g" $servicefile
sed -i "s/__publicPortName__/$serviceportname/g" $servicefile
sed -i "s/__publicPort__/$serviceport/g" $servicefile
sed -i "s/__rcName__/$rcname/g" $servicefile

cp $rcfile $manifestsPath/rc_latest.$template_extension
cp $servicefile $manifestsPath/service_latest.$template_extension

echo "Manifests generated"
