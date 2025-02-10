#!/bin/bash
echo "started the script"

# Variables
baseUrl="$1"
keyvaultName="$2"
requirementFile="requirements.txt"
requirementFileUrl=${baseUrl}"infra/scripts/index_scripts/requirements.txt"

echo "Script Started"

# Download the create_index and create table python files
curl --output "01_create_search_index.py" ${baseUrl}"infra/scripts/index_scripts/01_create_search_index.py"
curl --output "02_create_cu_template_text.py" ${baseUrl}"infra/scripts/index_scripts/02_create_cu_template_text.py"
curl --output "02_create_cu_template_audio.py" ${baseUrl}"infra/scripts/index_scripts/02_create_cu_template_audio.py"
curl --output "03_cu_process_data_text.py" ${baseUrl}"infra/scripts/index_scripts/03_cu_process_data_text.py"
curl --output "content_understanding_client.py" ${baseUrl}"infra/scripts/index_scripts/content_understanding_client.py"
curl --output "ckm-analyzer_config_text.json" ${baseUrl}"infra/data/ckm-analyzer_config_text.json"
curl --output "ckm-analyzer_config_audio.json" ${baseUrl}"infra/data/ckm-analyzer_config_audio.json"

curl --output "sample_processed_data.json" ${baseUrl}"infra/data/sample_processed_data.json"
curl --output "sample_processed_data_key_phrases.json" ${baseUrl}"infra/data/sample_processed_data_key_phrases.json"
curl --output "sample_search_index_data.json" ${baseUrl}"infra/data/sample_search_index_data.json"

# Install system dependencies for pyodbc
echo "Installing system packages..."
apk add --no-cache --virtual .build-deps \
    build-base \
    unixodbc-dev
#Download the desired package(s)
curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/msodbcsql18_18.4.1.1-1_amd64.apk
curl -O https://download.microsoft.com/download/7/6/d/76de322a-d860-4894-9945-f0cc5d6a45f8/mssql-tools18_18.4.1.1-1_amd64.apk
#Install the package(s)
apk add --allow-untrusted msodbcsql18_18.4.1.1-1_amd64.apk
apk add --allow-untrusted mssql-tools18_18.4.1.1-1_amd64.apk

# Download the requirement file
curl --output "$requirementFile" "$requirementFileUrl"

echo "Download completed"

#Replace key vault name 
sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "01_create_search_index.py"
sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "02_create_cu_template_text.py"
sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "02_create_cu_template_audio.py"
sed -i "s/kv_to-be-replaced/${keyvaultName}/g" "03_cu_process_data_text.py"

pip install -r requirements.txt

python 01_create_search_index.py
python 02_create_cu_template_text.py
python 02_create_cu_template_audio.py
python 03_cu_process_data_text.py