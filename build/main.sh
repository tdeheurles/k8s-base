# import data
. ./config/release.cfg

# Control if local build and prepare for it if needed
. ./config/localbuild.cfg 2&>/dev/null
if [[ -n $local_build ]]; then
  echo -e "\e[96mmain.sh:\e[39m build will be local"
  . ./build/localbuildnumber 2&>/dev/null

  if [[ -z $LATEST_BUILD_NUMBER ]]; then
    BUILD_NUMBER=0
  else
    BUILD_NUMBER=$(($LATEST_BUILD_NUMBER+1))
  fi

  echo "LATEST_BUILD_NUMBER=$BUILD_NUMBER" > ./build/localbuildnumber
fi

# name artifact
artifact_name="gcr.io/$projectid/$servicename"
artifact_tag="$artifact_name:$servicemajor.$serviceminor.$BUILD_NUMBER"
echo -e "\e[96mmain.sh:\e[39m artifact will be : $artifact_tag"

# Prepare container
echo -e "\e[96mmain.sh:\e[39m preparing container"
mkdir -p ./build/container
sed "s/__SERVICEPORT__/$serviceport1/g" ./build/template.Dockerfile > ./build/container/Dockerfile
cp ./src/*    ./build/container/
docker build -t $artifact_name ./build/container/
docker tag -f $artifact_name $artifact_tag

# Push to Google Cloud Engine
if [[ -z $local_build ]]; then
  echo -e "\e[96mmain.sh:\e[39m Pushing to Google Cloud Container Registry"
  gcloud docker push $artifact_name
  gcloud docker push $artifact_tag
fi

# generate manifests
echo -e "\e[96mmain.sh:\e[39m Generating manifests"
deployPath=./deploy/kubernetes
rm $deployPath/*.json 2&>/dev/null
rm $deployPath/*.yml 2&>/dev/null
$deployPath/createManifests.sh $artifact_tag $BUILD_NUMBER
