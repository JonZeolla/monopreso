# Prep
export ZENABLE_LLM="BEDROCK"
export ZENABLE_BEDROCK__MODEL_ID="anthropic.claude-3-sonnet-20240229-v1:0"
export ZENABLE_LOGLEVEL="WARNING"
#export ZENABLE_LOGLEVEL="DEBUG"
export PROJECT=csa_birmingham
export monorepo=/Users/jonzeolla/src/zenable/next-gen-governance/

cd ${monorepo}/services/document_ingestion
task init
task build
cd ${monorepo}/services/analysis
task init
INIT_AT_BUILD=True task build #-f


# Demo
docker volume rm -f ${PROJECT}_postgres_data || true

cd ${monorepo}/services/document_ingestion
task start
task run
task stop

sleep 5

cd ${monorepo}/services/analysis
task start
task run
