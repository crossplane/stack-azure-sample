#!/usr/bin/env bash

KEYFILE="/tmp/crossplane-azure-provider-key.json"
function clean() {
  rm -rf $KEYFILE
}
trap clean EXIT

# create service principal with Owner role
az ad sp create-for-rbac --sdk-auth --role Owner > "${KEYFILE}"
AZURE_CLIENT_ID=$(jq -r ".clientId" < "${KEYFILE}")

# add required Azure Active Directory permissions
az ad app permission add --id "${AZURE_CLIENT_ID}" --api 00000002-0000-0000-c000-000000000000 --api-permissions 1cda74f2-2616-4834-b122-5cb1b07f8a59=Role 78c8a3c8-a07e-4b9e-af1b-b5ccab50a175=Role

# grant (activate) the permissions
az ad app permission grant --id "${AZURE_CLIENT_ID}" --api 00000002-0000-0000-c000-000000000000 --expires never > /dev/null

cat <<EOS

********************
$(cat $KEYFILE)
********************

Your Minimal Azure Stack keyfile is shown above, between the asterisks.
EOS
