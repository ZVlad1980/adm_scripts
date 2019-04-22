#!/usr/bin/env bash

sudo -u mdm nohup /informatica/infa_home/PDH/scripts/launch_gateway.sh -OM ReportGenerator -OA BUILD -OP P_ROWID_SYSTEM=JANIS -OP P_PRODUCT_TYPE=JOURNAL PDH_QA_EXCEPTION wf_PDH_GATEWAY &
