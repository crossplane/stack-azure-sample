#!/usr/bin/env bash

set -ex

KEYFILE="/tmp/crossplane-azure-provider-key.json"
function clean() {
  rm -rf $KEYFILE
}
trap clean EXIT

# create service principal with Owner role
az ad sp create-for-rbac --sdk-auth --role Owner > "${KEYFILE}"

# add required Azure Active Directory permissions
AZURE_CLIENT_ID=$(jq -r ".clientId" < "${KEYFILE}")

# https://docs.microsoft.com/en-us/archive/blogs/aaddevsup/guid-table-for-windows-azure-active-directory-permissions
# https://docs.microsoft.com/en-us/cli/azure/ad/app/permission?view=azure-cli-latest 
RW_ALL_APPS=1cda74f2-2616-4834-b122-5cb1b07f8a59
RW_DIR_DATA=78c8a3c8-a07e-4b9e-af1b-b5ccab50a175
AAD_GRAPH_API=00000002-0000-0000-c000-000000000000

az ad app permission add --id "${AZURE_CLIENT_ID}" --api ${AAD_GRAPH_API} --api-permissions ${RW_ALL_APPS}=Role ${RW_DIR_DATA}=Role
az ad app permission grant --id "${AZURE_CLIENT_ID}" --api ${AAD_GRAPH_API} --expires never > /dev/null
az ad app permission admin-consent --id "${AZURE_CLIENT_ID}"

cat <<EOS

********************
$(cat $KEYFILE)
********************

Your Azure Sample Stack keyfile is shown above, between the asterisks.
EOS
