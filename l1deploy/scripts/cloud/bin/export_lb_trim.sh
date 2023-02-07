#!/bin/sh
INSTALL_HOME=$(dirname $0 | xargs -I {} realpath {} | rev | cut -d '/' -f 2- | rev)
cd $INSTALL_HOME

cd model

rm anki*.xml
sed -i '/file="anki/d' controller.xml
rm cps*.xml
sed -i '/file="cps/d' controller.xml
rm bi_cps*.xml
sed -i '/file="bi_cps/d' controller.xml
rm sailgp*.xml
sed -i '/file="sailgp/d' controller.xml
rm bi_sailgp*.xml
sed -i '/file="bi_sailgp/d' controller.xml
rm function_bad*.xml
sed -i '/file="function_bad/d' controller.xml
rm procedure_bad*.xml
sed -i '/file="procedure_bad/d' controller.xml
rm package_spec_bad*.xml
sed -i '/file="package_spec_bad/d' controller.xml
rm dr?idx*.xml
sed -i '/file="dr$idx/d' controller.xml
rm aurc*.xml
sed -i '/file="aurc/d' controller.xml
rm rdm*.xml
sed -i '/file="rdm/d' controller.xml
rm bi_rdm*.xml
sed -i '/file="bi_rdm/d' controller.xml
rm v_*.xml
sed -i '/file="v_/d' controller.xml
rm  cw_*.xml
sed -i '/file="cw_/d' controller.xml
rm driver_upload_table.xml
sed -i '/file="driver_upload_table/d' controller.xml
rm dvr_rocket_table.xml
sed -i '/file="dvr_rocket_table/d' controller.xml
rm emp_table.xml
sed -i '/file="emp_table/d' controller.xml
rm iot*.xml
sed -i '/file="iot/d' controller.xml
rm ocr_*.xml
sed -i '/file="ocr_/d' controller.xml
rm temp_t_table.xml
sed -i '/file="temp_t_table/d' controller.xml
rm wc_teams_table.xml
sed -i '/file="wc_teams_table/d' controller.xml
rm weather_table.xml
sed -i '/file="weather_table/d' controller.xml
rm htmldb_plan_table_table.xml
sed -i '/file="htmldb_plan_table/d' controller.xml
rm worldcupmatches_table.xml
sed -i '/file="worldcupmatches_table/d' controller.xml
rm ws_measurements_table.xml
sed -i '/file="ws_measurements_table/d' controller.xml
rm ft-*.xml
sed -i '/file="ft-/d' controller.xml
rm bi_f1_racers_trigger.xml
sed -i '/file="bi_f1_racers_trigger/d' controller.xml
rm f1-data-races_table.xml
sed -i '/file="f1-data-races_table/d' controller.xml
rm f1_cardatav2_view.xml
sed -i '/file="f1_cardatav2_view/d' controller.xml
rm f1_cardatav_view.xml
sed -i '/file="f1_cardatav_view/d' controller.xml
rm f1_lap_seq_view.xml
sed -i '/file="f1_lap_seq_view/d' controller.xml
rm f1_lap_t1_trigger.xml
sed -i '/file="f1_lap_t1_trigger/d' controller.xml
rm f1_lapdata_table.xml
sed -i '/file="f1_lapdata_table/d' controller.xml
rm f1_lapdatav_view.xml
sed -i '/file="f1_lapdatav_view/d' controller.xml
rm f1_leaderboard_view.xml
sed -i '/file="f1_leaderboard_view/d' controller.xml
rm f1_live_leaderboard_view.xml
sed -i '/file="f1_live_leaderboard_view/d' controller.xml
rm f1_members_table.xml
sed -i '/file="f1_members_table/d' controller.xml
rm f1_motion_seq_view.xml
sed -i '/file="f1_motion_seq_view/d' controller.xml
rm f1_motion_t1_trigger.xml
sed -i '/file="f1_motion_t1_trigger/d' controller.xml
rm f1_motion_table.xml
sed -i '/file="f1_motion_table/d' controller.xml
rm f1_motionv_view.xml
sed -i '/file="f1_motionv_view/d' controller.xml
rm f1_racers_table.xml
sed -i '/file="f1_racers_table/d' controller.xml
rm f1_session_seq_view.xml
sed -i '/file="f1_session_seq_view/d' controller.xml
rm f1_session_table.xml
sed -i '/file="f1_session_table/d' controller.xml
rm f1_tele_t1_trigger.xml
sed -i '/file="f1_tele_t1_trigger/d' controller.xml
rm f1_telemetry_seq_view.xml
sed -i '/file="f1_telemetry_seq_view/d' controller.xml
rm f1_telemetry_table.xml
sed -i '/file="f1_telemetry_table/d' controller.xml
rm f1_telemetryv_view.xml
sed -i '/file="f1_telemetryv_view/d' controller.xml
rm f1_trackdata_table.xml
sed -i '/file="f1_trackdata_table/d' controller.xml
rm f1tst-sessiondata_table.xml
sed -i '/file="f1tst-sessiondata_table/d' controller.xml
rm vf1_fastestlaps_view.xml
sed -i '/file="vf1_fastestlaps_view/d' controller.xml
rm ltpk_id_index.xml
sed -i '/file="ltpk_id_index/d' controller.xml
rm 'i_os$_mv_f1sim_lapdata_index.xml'
sed -i '/file="i_os$_mv_f1sim_lapdata_index/d' controller.xml

# add stripping on any anziot from the code
find . -name "*.xml" -exec sed -i 's/ANZIOT\.//g' {} \;
find . -name "*.xml" -exec sed -i 's/anziot\.//g' {} \;
find . -name "*.xml" -exec sed -i 's/"ANZIOT"\.//g' {} \;
find . -name "*.xml" -exec sed -i 's/"anziot"\.//g' {} \;

cd -
cd application

# add stripping on any anziot from the code
sed -i "s/ANZIOT\.//g" f134.sql
sed -i "s/anziot\.//g" f134.sql
sed -i "s/ANZIOT\.//g" f166.sql
sed -i "s/anziot\.//g" f166.sql

cd -
