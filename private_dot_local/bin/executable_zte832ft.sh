#!/bin/bash

curl --header "Referer: http://192.168.99.1/index.html" "http://192.168.99.1/goform/goform_get_cmd_process?cmd=signalbar,wan_csq,network_type,network_provider,ppp_status,modem_main_state,rmcc,rmnc,domain_stat,cell_id,lac_code,rssi,rscp,lte_rssi,lte_rsrq,lte_rsrp,lte_snr,ecio,sms_received_flag,sts_received_flag,simcard_roam,cbm_r&multi_data=1&sms_received_flag_flag=0&sts_received_flag_flag=0cbm_received_flag_flag=0"

curl --header "Referer: http://192.168.99.1/index.html" "http://192.168.99.1/goform/goform_set_cmd_process?goformId=SET_CONNECTION_MODE&ConnectionMode=auto_dial"

curl --header "Referer: http://192.168.99.1/index.html" "http://192.168.99.1/goform/goform_get_cmd_process?cmd=signalbar,wan_csq,network_type,network_provider,ppp_status,modem_main_state,rmcc,rmnc,domain_stat,cell_id,lac_code,rssi,rscp,lte_rssi,lte_rsrq,lte_rsrp,lte_snr,ecio,sms_received_flag,sts_received_flag,simcard_roam,cbm_r&multi_data=1&sms_received_flag_flag=0&sts_received_flag_flag=0cbm_received_flag_flag=0"
