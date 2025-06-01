--
-- PostgreSQL database dump
--

-- Dumped from database version 16.4
-- Dumped by pg_dump version 16.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: component_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.component_charts VALUES ('youbike_availability', '{#9DC56E,#356340,#9DC56E}', '{GuageChart,BarPercentChart}', '輛');
INSERT INTO public.component_charts VALUES ('ebus_percent', '{#9DC56E,#356340,#9DC56E}', '{IconPercentChart,BarPercentChart}', '輛');
INSERT INTO public.component_charts VALUES ('city_age_distribution', '{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}', '{DistrictChart,ColumnChart}', '仟人');
INSERT INTO public.component_charts VALUES ('dependency_aging', '{#67baca,#fbf3ac}', '{ColumnLineChart,TimelineSeparateChart}', '%');
INSERT INTO public.component_charts VALUES ('aging_kpi', '{#F65658,#F49F36,#F5C860,#9AC17C,#4CB495,#569C9A,#60819C,#2F8AB1}', '{TextUnitChart}', NULL);
INSERT INTO public.component_charts VALUES ('aging_workforce_trend', '{#24B0DD,#56B96D,#F8CF58,#F5AD4A,#E170A6,#ED6A45,#AF4137,#10294A}', '{BarPercentChart,RadarChart,ColumnChart}', '%');
INSERT INTO public.component_charts VALUES ('bike_network', '{#a0b8e8,#b7ff98}', '{DonutChart,BarChart}', '公里');
INSERT INTO public.component_charts VALUES ('bike_map', '{#a0b8e8,#b7ff98}', '{MapLegend}', '條');
INSERT INTO public.component_charts VALUES ('quiz_component', '{#667eea,#764ba2,#9c88ff,#a29bfe,#6c5ce7,#74b9ff}', '{QuizChart}', '推薦');
INSERT INTO public.component_charts VALUES ('commercial_district_density', '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}', '{DistrictChart}', '個');
INSERT INTO public.component_charts VALUES ('commercial_district_density_metrotaipei', '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}', '{DistrictChart}', '個');
INSERT INTO public.component_charts VALUES ('commercial_district_ranking_metrotaipei', '{#FF6B6B,#4ECDC4,#45B7D1,#96CEB4,#FFEEAD,#D4A5A5,#9B59B6,#3498DB}', '{CommercialDistrictRanking}', '個');


--
-- Data for Name: component_maps; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.component_maps VALUES (70, 'youbike_realtime', 'youbike站點', 'symbol', 'geojson', NULL, 'youbike', '{}', '[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]');
INSERT INTO public.component_maps VALUES (99, 'youbike_realtime_metrotaipei', 'youbike站點', 'symbol', 'geojson', NULL, 'youbike', '{}', '[{"key":"sna","name":"場站名稱"},{"key":"sno","name":"場站ID"},{"key":"available_return_bikes","name":"可還車位"},{"key":"available_rent_general_bikes","name":"剩餘車輛"}]');
INSERT INTO public.component_maps VALUES (100, 'bike_network_tpe', '自行車路網', 'line', 'geojson', NULL, NULL, '{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}', '[
  {"key": "data_time", "name": "數據時間"},
  {"key": "route_name", "name": "路線名稱"},
  {"key": "city_code", "name": "城市代碼"},
  {"key": "city", "name": "城市"},
  {"key": "road_section_start", "name": "起點路段"},
  {"key": "road_section_end", "name": "終點路段"},
  {"key": "direction", "name": "方向"},
  {"key": "cycling_length", "name": "自行車道長度"},
  {"key": "finished_time", "name": "完工時間"},
  {"key": "update_time", "name": "更新時間"}
]');
INSERT INTO public.component_maps VALUES (101, 'bike_network_metrotaipei', '自行車路網', 'line', 'geojson', NULL, NULL, '{"line-color":["match",["get","direction"],"雙向","#097138","單向","#007BFF","#808080"]}', '[
  {"key": "data_time", "name": "數據時間"},
  {"key": "route_name", "name": "路線名稱"},
  {"key": "city_code", "name": "城市代碼"},
  {"key": "city", "name": "城市"},
  {"key": "road_section_start", "name": "起點路段"},
  {"key": "road_section_end", "name": "終點路段"},
  {"key": "direction", "name": "方向"},
  {"key": "cycling_length", "name": "自行車道長度"},
  {"key": "finished_time", "name": "完工時間"},
  {"key": "update_time", "name": "更新時間"}
]');
INSERT INTO public.component_maps VALUES (14, 'market_events_metrotaipei', '雙北市集活動分佈 - 動態狀態', 'circle', 'geojson', 'big', NULL, '{"circle-color":["match",["get","event_status"],"not_started","#2196F3","active","#4CAF50","ending_2weeks","#FFEB3B","ending_1week","#FF9800","ending_3days","#F44336","#666666"],"circle-radius":["interpolate",["linear"],["zoom"],11.99,4,12,5,13.5,6,15,8,22,12],"circle-stroke-width":2,"circle-stroke-color":"#FFFFFF","circle-opacity":0.85}', '[{"key":"name","name":"市集名稱"},{"key":"type","name":"活動類型"},{"key":"district","name":"行政區"},{"key":"start_date","name":"開始日期"},{"key":"end_date","name":"結束日期"},{"key":"event_status","name":"活動狀態"},{"key":"description","name":"活動描述"}]');
INSERT INTO public.component_maps VALUES (13, 'market_events_taipei', '台北市集活動分佈 - 動態狀態', 'circle', 'geojson', 'big', NULL, '{"circle-color":["match",["get","event_status"],"not_started","#2196F3","active","#4CAF50","ending_2weeks","#FFEB3B","ending_1week","#FF9800","ending_3days","#F44336","#666666"],"circle-radius":["interpolate",["linear"],["zoom"],11.99,4,12,5,13.5,6,15,8,22,12],"circle-stroke-width":2,"circle-stroke-color":"#FFFFFF","circle-opacity":0.85}', '[{"key":"name","name":"市集名稱"},{"key":"type","name":"活動類型"},{"key":"district","name":"行政區"},{"key":"start_date","name":"開始日期"},{"key":"end_date","name":"結束日期"},{"key":"event_status","name":"活動狀態"},{"key":"description","name":"活動描述"}]');


--
-- Data for Name: components; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.components VALUES (60, 'youbike_availability', 'YouBike使用情況');
INSERT INTO public.components VALUES (213, 'bike_network', '自行車道路統計資料');
INSERT INTO public.components VALUES (212, 'ebus_percent', '電動巴士比例');
INSERT INTO public.components VALUES (214, 'dependency_aging', '扶養比及老化指數');
INSERT INTO public.components VALUES (216, 'city_age_distribution', '全市年齡分區');
INSERT INTO public.components VALUES (218, 'aging_kpi', '長照指標');
INSERT INTO public.components VALUES (215, 'aging_workforce_trend', '高齡就業人口之年增結構');
INSERT INTO public.components VALUES (217, 'bike_map', '自行車道路網圖資');
INSERT INTO public.components VALUES (220, 'commercial_district_density', '市集活動分佈');
INSERT INTO public.components VALUES (61, 'commercial_district_ranking_metrotaipei', '雙北商圈排行榜');
INSERT INTO public.components VALUES (222, 'commercial_district_density_metrotaipei', '雙北市集活動分佈');
INSERT INTO public.components VALUES (223, 'quiz_component', '台北商圈心理測驗');


--
-- Data for Name: contributors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.contributors VALUES (1, 'doit', '臺北市政府資訊局', 'doit.png', 'https://doit.gov.taipei/', NULL, NULL, false, '2024-05-09 01:58:47.164185+00', '2024-05-09 01:58:47.164185+00');
INSERT INTO public.contributors VALUES (2, 'ntpc', '新北市政府資訊中心', 'ntpc.png', 'https://www.imc.ntpc.gov.tw/', NULL, NULL, false, '2024-05-09 01:58:47.164185+00', '2024-05-09 01:58:47.164185+00');


--
-- Data for Name: dashboards; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dashboards VALUES (106, 'map-layers-taipei', '圖資資訊', '{217}', 'public', '2025-03-12 01:59:00.512775+00', '2024-03-21 10:04:24.928533+00');
INSERT INTO public.dashboards VALUES (356, 'ltc_care_tpe', '長照關懷', '{214,215,216,218}', 'elderly', '2025-02-26 08:43:42.86017+00', '2024-03-21 09:38:37.66+00');
INSERT INTO public.dashboards VALUES (355, 'ltc_care_newtpe', '長照關懷', '{214,215,216,218}', 'elderly', '2025-02-27 06:42:21.705931+00', '2024-03-21 09:38:37.66+00');
INSERT INTO public.dashboards VALUES (359, 'map-layers-metrotaipei', '圖資資訊', '{217}', 'public', '2024-05-16 03:56:12.76016+00', '2024-03-21 10:04:24.928533+00');
INSERT INTO public.dashboards VALUES (358, 'practical_transportation_newtpe', '務實交通', '{60,212,213}', 'directions_car', '2025-03-12 08:00:38.75842+00', '2024-03-21 09:38:37.66+00');
INSERT INTO public.dashboards VALUES (1, '09a25cd9cb7d', '收藏組件', NULL, 'favorite', '2025-03-14 07:34:22.247753+00', '2025-03-14 07:34:22.247753+00');
INSERT INTO public.dashboards VALUES (2, '3245d9eace5f', '我的新儀表板', '{215,218,216,213,212,214,60,146}', 'star', '2025-03-14 14:55:11.732116+00', '2025-03-14 14:55:11.732116+00');
INSERT INTO public.dashboards VALUES (360, '5a49ee3bd2f1', '收藏組件', NULL, 'favorite', '2025-05-26 12:09:41.648926+00', '2025-05-26 12:09:41.648926+00');
INSERT INTO public.dashboards VALUES (381, 'quiz_dashboard', '商圈探索測驗', '{223}', 'psychology', '2025-06-01 00:05:36.874327+00', '2025-06-01 00:05:36.874327+00');
INSERT INTO public.dashboards VALUES (361, 'commercial_district', '商圈活化', '{220,223}', 'store', '2025-05-31 18:53:37.261191+00', '2025-05-31 07:03:13.698496+00');
INSERT INTO public.dashboards VALUES (363, 'commercial_district_metrotaipei', '商圈活化', '{222,61}', 'store', '2025-05-31 18:54:10.771376+00', '2025-05-31 07:21:58.257472+00');


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.groups VALUES (1, 'public', false, NULL);
INSERT INTO public.groups VALUES (2, 'taipei', false, NULL);
INSERT INTO public.groups VALUES (3, 'metrotaipei', false, NULL);
INSERT INTO public.groups VALUES (4, 'user: 1''s personal group', true, 1);


--
-- Data for Name: dashboard_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.dashboard_groups VALUES (106, 2);
INSERT INTO public.dashboard_groups VALUES (356, 2);
INSERT INTO public.dashboard_groups VALUES (355, 3);
INSERT INTO public.dashboard_groups VALUES (359, 3);
INSERT INTO public.dashboard_groups VALUES (358, 3);
INSERT INTO public.dashboard_groups VALUES (360, 4);
INSERT INTO public.dashboard_groups VALUES (361, 2);
INSERT INTO public.dashboard_groups VALUES (363, 3);


--
-- Data for Name: query_charts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.query_charts VALUES ('aging_kpi', NULL, '{}', '{}', 'static', NULL, 0, NULL, '主計處', '此圖顯示雙北長照關懷各項指標。', '此圖表呈現雙北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。', '在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。', '{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}', '{doit,ntpc}', '2023-12-20 05:56:00+00', '2024-06-12 06:02:41.642+00', 'three_d', 'select y_axis,icon ,round(avg(data))data  
from(
select ''扶老比'' as y_axis, percent30 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''扶幼比'' as y_axis, percent31 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''扶養比'' as y_axis, percent32 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''老化指數'' as y_axis, percent33 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''扶老比'' as y_axis, avg(percent30) as data ,''%'' as icon 
from public.city_age_distribution_newtaipei 
where 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型=''計''
union all
select ''扶幼比'' as y_axis, avg(percent31) as data ,''%'' as icon 
from public.city_age_distribution_newtaipei 
where 年份= (select max(年份) from public.city_age_distribution_newtaipei ) and 統計類型=''計''
union all
select ''扶養比'' as y_axis, avg(percent32) as data ,''%'' as icon 
from public.city_age_distribution_newtaipei 
where 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型=''計''
union all
select ''老化指數'' as y_axis, avg(percent33) as data ,''%'' as icon 
from public.city_age_distribution_newtaipei 
where 年份= (select max(年份) from public.city_age_distribution_newtaipei )  and 統計類型=''計''
)d
group by y_axis,icon', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('aging_kpi', NULL, '{}', '{}', 'static', NULL, 0, NULL, '主計處', '此圖顯示臺北長照關懷各項指標。', '此圖表呈現臺北長照關懷相關指標，包括 扶老比、扶幼比、扶養比 及 老化指數。扶老比代表每百名勞動人口需扶養的老年人口數，扶幼比則是需扶養的兒童人口數，而扶養比則合計這兩者，反映整體社會負擔程度。老化指數則比較老年人口與兒童人口比例，顯示人口結構的高齡化趨勢。這些數據可用於評估長照需求，並規劃資源分配與政策方向，以因應人口老化帶來的挑戰。', '在制定長照政策時，政府可運用 扶老比、扶幼比、扶養比 及 老化指數 來評估未來照護需求。例如，某城市發現扶老比上升且老化指數超過 100，代表老年人口已多於兒童，預示長照需求將持續增加。政府可據此增設長照機構、強化居家照護服務，並鼓勵社區共融計畫，以減輕勞動人口的扶養壓力，確保高齡者獲得適切照顧。', '{https://data.taipei/dataset/detail?id=64c8a3a0-3b9a-4f49-a13a-fb1eb2ffa4b1}', '{doit}', '2023-12-20 05:56:00+00', '2024-06-12 06:02:41.642+00', 'three_d', 'select y_axis,icon ,round(avg(data))data  
from(
select ''扶老比'' as y_axis, percent30 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''扶幼比'' as y_axis, percent31 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''扶養比'' as y_axis, percent32 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
union all
select ''老化指數'' as y_axis, percent33 as data ,''%'' as icon 
from public.city_age_distribution_taipei 
where 年份= (select max(年份) from public.city_age_distribution_taipei ) and  區域別=''總計'' and 統計類型=''計''
)d
group by y_axis,icon', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('aging_workforce_trend', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示雙北就業人口之年齡結構時間數列統計資料', '雙北地區人口年齡分配按月別時間數列統計資料，記錄臺北市與新北市各年齡層人口數的月度變化，涵蓋從0歲至65歲以上等多個年齡區間。該資料反映雙北地區人口在不同年齡層之分布情形，具備連續性與時間性，可作為分析區域人口結構、行政規劃及社會資源配置的重要參考。透過長期追蹤，亦能協助了解人口構成在不同時間點的變化狀況與組成比例，有助於支持各項人口相關研究與實務應用。', '適用於跨域分析或探討都市群體共通趨勢，涵蓋臺北市與新北市兩地，常見於區域整體發展、通勤流動、就業市場整合、住宅與交通規劃等議題。亦可用於比較兩市人口結構差異、公共資源分布或整合性施政評估。例如：雙北地區勞動參與率變化、雙北通勤族群結構分析、雙北教育資源均衡程度探討等。', '{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b,https://data.ntpc.gov.tw/datasets/c285509a-7fb2-434f-8542-0b4986c337a8}', '{doit,ntpc}', '2024-11-28 05:56:00+00', '2024-12-10 02:59:39.341+00', 'three_d', 'select x_axis,y_axis,round(avg(percentage)) as data
from (select year as x_axis,''1.非高齡就業人口'' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe
where  gender =''總計'' and age_structure not in (''就業人口'',''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'',''就業人口按年齡別/65歲以上'')
group by year 
union all 
select year as x_axis,''2.中高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'')
union all 
select year as x_axis,''3.高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/65歲以上'')
union all 
select year as x_axis,''1.非高齡就業人口'' as y_axis,sum(percentage) as data  from employment_age_structure_new_tpe
where  gender =''總計'' and age_structure not in (''就業人口'',''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'',''就業人口按年齡別/65歲以上'')
group by year 
union all 
select year as x_axis,''2.中高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_new_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'')
union all 
select year as x_axis,''3.高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_new_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/65歲以上''))d
where x_axis >''2016''
group by x_axis,y_axis 
order by 1,2', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('aging_workforce_trend', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示臺北就業人口之年齡結構時間數列統計資料', '臺北市人口年齡分配按月別時間數列統計資料，提供各年齡層人口數的定期統計結果，依月別呈現，涵蓋從幼年、青壯年至高齡等不同年齡區間。此資料可作為觀察人口結構組成的重要依據，反映各年齡層在人口總數中的分布情形。透過持續的月別紀錄，可供相關單位進行人口結構分析、資源分配規劃及政策評估等多元應用。資料內容具體、連續，適合用於進行長期與跨時比較之研究分析。', '適用於聚焦單一行政區之人口、就業、教育、社會福利、都市規劃等議題。多用於市政層級的政策分析、市內人口結構觀察、社會服務配置研究，以及針對臺北市特定區域（如中正區、大安區等）的細部分析。例如：臺北市高齡人口比例變化、臺北市各區幼兒園分布狀況等。', '{https://data.taipei/dataset/detail?id=df320c78-f66b-4504-92b4-cf2a2eb46f1b}', '{doit}', '2024-11-28 05:56:00+00', '2025-03-19 10:25:55.340887+00', 'three_d', 'select x_axis,y_axis,round(avg(percentage)) as data
from (select year as x_axis,''1.非高齡就業人口'' as y_axis,sum(percentage) as percentage  from employment_age_structure_tpe
where  gender =''總計'' and age_structure not in (''就業人口'',''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'',''就業人口按年齡別/65歲以上'')
group by year 
union all 
select year as x_axis,''2.中高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/45-49歲'',''就業人口按年齡別/50-54歲'',''就業人口按年齡別/55-59歲'',''就業人口按年齡別/60-64歲'')
union all 
select year as x_axis,''3.高齡就業人口'' as y_axis,percentage as data  from employment_age_structure_tpe
where  gender =''總計'' and age_structure  in (''就業人口按年齡別/65歲以上'')
)d
where x_axis >''2016''
group by x_axis,y_axis 
order by 1,2', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('bike_map', NULL, '{100,101}', '{}', 'static', NULL, NULL, NULL, '交通局交工處', '顯示雙北當前自行車路網分布。', '顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。', '使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。', '{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}', '{doit,ntpc}', '2023-12-20 05:56:00+00', '2024-01-11 06:26:02.069+00', 'map_legend', 'SELECT unnest(array[''自行車路網'']) as name, ''line'' as type', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('bike_map', NULL, '{100}', '{}', 'static', NULL, NULL, NULL, '交通局交工處', '顯示臺北當前自行車路網分布。', '顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要由河濱自行車道與市區自行車道組成。河濱自行車道沿淡水河、基隆河、新店溪與景美溪等河岸規劃，提供連續、寬敞且景觀良好的騎行空間，深受市民與遊客喜愛。市區自行車道則分布於市內多條主要幹道，包括敦化南北路、承德路、松隆路、松德路、和平西路、民生東路、八德路、光復南路、永吉路等，串聯重要商圈、學區與轉運點，提升日常通勤與短程移動的便利性。臺北市政府持續推動「自行車道願景計畫」，整合市區與河濱車道系統、銜接捷運與轉乘據點，並優化既有路線與設施，致力打造友善、安全的騎乘環境。', '使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。', '{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}', '{doit}', '2023-12-20 05:56:00+00', '2024-01-11 06:26:02.069+00', 'map_legend', 'SELECT unnest(array[''自行車路網'']) as name, ''line'' as type', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('bike_network', NULL, '{100,101}', '{"mode":"byParam","byParam":{"xParam":"direction"}}', 'static', NULL, NULL, NULL, '交通局交工處', '顯示雙北當前自行車路網分布。', '顯示雙北當前自行車路網分布。雙北擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，雙北政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。', '使用於地圖分析、交通規劃與旅遊建議，雙北的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。', '{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/NewTaipei?%24top=30&%24format=JSON}', '{doit,ntpc}', '2023-12-20 05:56:00+00', '2024-01-11 06:26:02.069+00', 'two_d', 'select x_axis,sum(data)data from (select  direction as x_axis ,round(sum(cycling_length)/1000) as data
from public.bike_network_tpe  
group by direction
union all
select  direction as x_axis ,round(sum(cycling_length)/1000) as data
from public.bike_network_new_tpe  
group by direction
)d
where x_axis !=''''
group by x_axis', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('bike_network', NULL, '{100}', '{"mode":"byParam","byParam":{"xParam":"direction"}}', 'static', NULL, NULL, NULL, '交通局交工處', '顯示臺北市當前自行車路網分布。', '顯示臺北市當前自行車路網分布。臺北市擁有完善的自行車路網，主要包括河濱自行車道和市區自行車道。河濱自行車道沿淡水河、基隆河、新店溪和景美溪等河岸建設，提供連續且風景優美的騎行路線。市區自行車道則遍布於主要道路，如敦化南北路、成功路、承德路、松隆路、松德路、和平西路、民生東路、北安路、金湖路、八德路、大道路、光復南路和永吉路等，方便市民在城市中安全騎行。此外，臺北市政府持續推動「自行車道願景計畫」，以串聯既有路網、銜接跨市及河濱自行車道，並優化現有自行車道，提升騎行環境的便利性與安全性。', '使用於地圖分析、交通規劃與旅遊建議，臺北市的自行車路網可與其他圖資套疊，提供更深入的洞察。透過將自行車道與人口密度、交通流量或公車捷運路線交叉比對，可優化城市規劃，提高自行車友善程度。對於旅遊應用，可將自行車道與景點、商圈、飯店位置結合，推薦最佳騎行路線，提升遊憩體驗。此外，政府與企業可藉由數據分析發掘需求熱點，進一步優化自行車基礎設施與共享單車系統。', '{https://tdx.transportdata.tw/api/basic/v2/Cycling/Shape/City/Taipei?%24top=30&%24format=JSON}', '{doit}', '2023-12-20 05:56:00+00', '2024-01-11 06:26:02.069+00', 'two_d', 'select  direction as x_axis ,round(sum(cycling_length)/1000) as data
from public.bike_network_tpe  
where direction !=''''
group by direction', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('city_age_distribution', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示雙北年齡分區', '顯示雙北地區年齡分區，將人口依年齡群體劃分至不同城市區域。此分區有助於了解臺北市與新北市在人口結構上的差異與分布情形，包括各行政區的老化程度、青壯年與幼年人口比例，為政策制定者、城市規劃者及研究人員提供精確的分析依據。透過此資料，可進行跨區域的公共資源配置、社區規劃與長期照護服務設計，確保雙北地區在教育、交通、醫療與社福等層面能因應不同年齡層需求，促進整體都市發展的均衡與永續。', '使用於城市規劃、社會政策制定及人口統計分析，雙北地區年齡分區數據可協助政府與研究機構掌握人口結構的變化情形。此指標適用於評估各年齡層在臺北市與新北市的區域分布，有助於規劃教育資源配置、醫療設施布建及長照服務佈點。除此之外，企業亦可依據此數據進行市場分析，針對不同年齡族群設計產品與服務，強化區域經營策略的精準度與效益。此資料為雙北區域在政策與產業發展上的重要基礎依據。', '{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}', '{doit,ntpc}', '2024-11-28 05:56:00+00', '2025-03-20 01:33:28.634747+00', 'three_d', 'select x_axis,y_axis,round(sum(data)/1000) data
from(select 區域別 as x_axis,''0_14歲人口數'' as y_axis,percent24 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
union all
select 區域別 as x_axis,''15_64歲人口數'' as y_axis,percent26 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
union all
select 區域別 as x_axis,''65歲以上人口數'' as y_axis,percent28 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
union all
select 區域別 as x_axis,''0_14歲人口數'' as y_axis,percent24 as data
from 
public.city_age_distribution_newtaipei 
where 區域別 not in (''總計'',''新北市'') and 年份=(select max(年份)
from 
public.city_age_distribution_newtaipei)
union all
select 區域別 as x_axis,''15_64歲人口數'' as y_axis,percent26 as data
from 
public.city_age_distribution_newtaipei 
where 區域別 not in (''總計'',''新北市'') and 年份=(select max(年份)
from 
public.city_age_distribution_newtaipei)  
union all
select 區域別 as x_axis,''65歲以上人口數'' as y_axis,percent28 as data
from 
public.city_age_distribution_newtaipei 
where 區域別 not in (''總計'',''新北市'') and 年份=(select max(年份)
from 
public.city_age_distribution_newtaipei)
)d
group by x_axis,y_axis
', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('city_age_distribution', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示臺北市年齡分區', '顯示臺北市年齡分區，將市民人口依年齡群體劃分至不同行政區域。此分區有助於掌握各區人口結構分布，包括幼年人口、青壯年人口與高齡人口比例，為政策制定者、城市規劃單位及研究人員提供重要的分析依據。透過此資料，可進行公共資源配置、社區照護設計及設施規劃，確保臺北市在教育、醫療、交通與長照等方面的發展，能更貼近各年齡層居民的實際需求，促進人口結構與城市功能的平衡發展。', '使用於城市規劃、社會政策制定及人口統計分析，臺北市年齡分區數據可協助市府機關與研究單位掌握市內人口結構的變化。此指標適用於評估各年齡層在不同行政區的分布情形，有助於規劃教育資源、醫療設施及長照服務的佈局與優化。此外，企業亦可依據此資料進行在地市場分析，針對不同年齡族群設計產品與服務，提升區域經營策略的精準度與實效性，強化對臺北市多元人口需求的回應。








', '{https://data.taipei/dataset/detail?id=1e0c58e9-6aa5-4acb-a5a1-f60bacad60f3}', '{doit}', '2024-11-28 05:56:00+00', '2025-02-21 07:52:55.450103+00', 'three_d', 'select x_axis,y_axis,round(sum(data)/1000) data
from(select 區域別 as x_axis,''0_14歲人口數'' as y_axis,percent24 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
union all
select 區域別 as x_axis,''15_64歲人口數'' as y_axis,percent26 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
union all
select 區域別 as x_axis,''65歲以上人口數'' as y_axis,percent28 as data
from 
public.city_age_distribution_taipei 
where 區域別 != ''總計'' and 年份=(select max(年份)
from 
public.city_age_distribution_taipei)
)d
group by x_axis,y_axis
', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('dependency_aging', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示雙北扶養比及老化指數時間數列統計資料', '顯示雙北扶養比及老化指數時間數列統計資料。雙北政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析雙北人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。', '使用於人口結構分析、社會福利規劃與經濟發展評估，雙北的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。
', '{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698,https://data.ntpc.gov.tw/datasets/8308ab58-62d1-424e-8314-24b65b7ab492}', '{doit,ntpc}', '2024-11-28 05:56:00+00', '2024-12-10 02:59:39.341+00', 'time', 'select 
x_axis,y_axis,round(avg(data)) data
from (
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''扶養比'' as y_axis,total_dependency_ratio as data  
from 
dependency_ratio_and_aging_index_tpe
union all
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''老化指數'' as y_axis ,aging_index 
from 
dependency_ratio_and_aging_index_tpe
union all
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''扶養比'' as y_axis,total_dependency_ratio  
from 
dependency_ratio_and_aging_index_new_tpe
union all
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''老化指數'' as y_axis ,aging_index 
from 
dependency_ratio_and_aging_index_new_tpe
)d
where x_axis >''2013-01-01 00:00:00.000''
group by x_axis,y_axis
order by 1
', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('dependency_aging', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '主計處', '顯示臺北市扶養比及老化指數時間數列統計資料', '顯示臺北市扶養比及老化指數時間數列統計資料。臺北市政府主計處提供了扶養比和老化指數資料，詳細記錄了各年齡段人口比例的變化情況。這些資料有助於分析臺北市人口結構的演變，評估青壯年人口對幼年和老年人口的扶養負擔，以及社會老化程度。透過這些統計資料，政策制定者和研究人員可以深入了解人口趨勢，為未來的社會福利和經濟發展規劃提供參考。', '使用於人口結構分析、社會福利規劃與經濟發展評估，臺北市的扶養比與老化指數數據提供決策參考。政府機構可透過這些統計資料評估勞動力供給與社會扶養負擔，進而調整退休政策與醫療資源配置。企業可運用數據研判市場趨勢，規劃銀髮族產品與服務。學術研究則可透過時間序列分析，探討人口老化對經濟與社會的影響，為未來城市發展與人口政策提供科學依據。
', '{https://data.taipei/dataset/detail?id=aafb15dc-5508-4091-bd48-a708e60f6698}', '{doit}', '2024-11-28 05:56:00+00', '2025-02-25 01:43:21.031142+00', 'time', 'select 
x_axis,y_axis,round(avg(data)) data
from (
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''扶養比'' as y_axis,total_dependency_ratio as data  
from 
dependency_ratio_and_aging_index_tpe
union all
select TO_TIMESTAMP(end_of_year , ''YYYY-MM-DD HH24:MI:SS.MS'') AT TIME ZONE ''Asia/Taipei'' AS x_axis,
''老化指數'' as y_axis ,aging_index 
from 
dependency_ratio_and_aging_index_tpe
)d
where x_axis >''2013-01-01 00:00:00.000''
group by x_axis,y_axis
order by 1
', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('ebus_percent', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '交通局', '顯示雙北電動公車比例', '此圖顯示雙北地區電動公車的比例，呈現臺北市與新北市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及程度，及其對減碳、空氣品質改善的實質貢獻，進一步作為規劃大臺北地區公共運輸電動化策略的重要依據，推動都會區交通體系朝向低碳永續發展。', '可用於評估雙北地區公共運輸電動化進程，透過此圖顯示臺北市與新北市公車系統中電動公車的占比及成長趨勢。圖表比較傳統燃油公車與電動公車的比例變化，並標示雙北兩市推動相關政策、補助措施及其所帶來的環保效益。透過這些數據，可評估雙北地區電動公車的普及率，以及其在減碳排放與空氣品質改善上的具體貢獻，進而作為制定更完善的都會區公共運輸電動化策略的重要依據，推動雙北朝向低碳永續城市目標發展。', '{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON,https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/NewTaipei?%24top=30&%24format=JSON}', '{doit,ntpc}', '2025-02-15 05:56:00+00', '2024-02-15 02:59:39.341+00', 'percent', 'select ''電動公車數量'' as x_axis,y_axis,sum(data) data from 
(select ''電動巴士'' as y_axis,count(*) as  data
from public.bus_info_new_tpe
where plate_numb like ''E%''
union all
select ''非電動巴士'' as y_axis,count(*) as  data
from public.bus_info_new_tpe
where plate_numb not like ''E%''
union all
select ''電動巴士'' as y_axis,count(*) as  data
from public.bus_info_tpe
where plate_numb like ''E%''
union all
select ''非電動巴士'' as y_axis,count(*) as  data
from public.bus_info_tpe)d
group by 
y_axis
', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('ebus_percent', NULL, NULL, NULL, 'static', NULL, NULL, NULL, '交通局', '顯示臺北電動公車比例', '此圖顯示臺北市電動公車的比例，呈現全市公車車隊中電動車所占比重，以及近年來電動公車數量的成長情形。圖表比較傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動電動化政策、補助措施及其帶來的環保效益。透過這些數據，可評估臺北市電動公車的普及程度，及其在減碳與空氣品質改善上的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動城市交通朝向低碳永續目標邁進。', '可用於評估臺北市公共運輸電動化的進程，透過此圖顯示電動公車在市區公車總數中的占比及其成長趨勢。圖表呈現傳統燃油公車與電動公車的比例變化，並標示臺北市政府推動的政策措施、補助方案及相關環保效益等影響因素。透過這些數據，可分析臺北市電動公車的普及程度及其在減碳排放與空氣品質改善方面的貢獻，有助於進一步規劃更完善的公共運輸電動化策略，推動臺北朝向低碳與永續發展的城市目標邁進。', '{https://tdx.transportdata.tw/api/basic/v2/Bus/Vehicle/City/Taipei?%24top=30&%24format=JSON}', '{doit}', '2025-02-15 05:56:00+00', '2025-02-20 09:11:21.620625+00', 'percent', 'select ''電動公車數量'' as x_axis,y_axis,sum(data) data from 
(
select ''電動巴士'' as y_axis,count(*) as  data
from public.bus_info_tpe
where plate_numb like ''E%''
union all
select ''非電動巴士'' as y_axis,count(*) as  data
from public.bus_info_tpe)d
group by 
y_axis', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('youbike_availability', NULL, '{99}', NULL, 'current', NULL, 10, 'minute', '交通局', '顯示當前雙北共享單車YouBike的使用情況。', '顯示雙北地區（臺北市與新北市）當前共享單車 YouBike 的使用情況，格式為可借車輛數／全區車位數。資料來源為兩市交通局公開資料，每5分鐘更新一次，提供即時的車輛可用資訊與站點使用狀況，有助於掌握整體運行效率與民眾使用情形，亦可作為交通管理與營運調度的參考依據。', '藉由顯示雙北地區 YouBike 的使用情況，以及觀察可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與使用中車輛的整體分布情形。使用者亦可透過地圖模式查詢雙北各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便規劃路線與掌握使用狀況，提升共享單車的便利性與使用效率。', '{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181,https://tdx.transportdata.tw/api/basic/v2/Bike/Availability/City/NewTaipei?%24top=30&%24format=JSON}', '{doit,ntpc}', '2023-12-20 05:56:00+00', '2024-03-19 06:08:17.99+00', 'percent', 'select x_axis,y_axis,sum(data)data
from (select ''在站車輛'' as x_axis, 
unnest(ARRAY[''可借車輛'', ''空位'']) as y_axis, 
unnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data
from tran_ubike_realtime_new_tpe
union all 
select ''在站車輛'' as x_axis, 
unnest(ARRAY[''可借車輛'', ''空位'']) as y_axis, 
unnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data
from tran_ubike_realtime)d
group by x_axis,y_axis', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('youbike_availability', NULL, '{70}', NULL, 'current', NULL, 10, 'minute', '交通局', '顯示當前臺北市共享單車YouBike的使用情況。', '顯示臺北市當前共享單車 YouBike 的使用情況，格式為可借車輛數／全市車位數。資料來源為臺北市政府交通局公開資料，每5分鐘更新一次，反映即時的使用狀況與車輛調度情形，可作為交通監測與市民使用參考依據。', '藉由臺北市 YouBike 使用情況的顯示，以及全市可借車輛數約為車柱總數的一半，可大致掌握目前停放於站點與正在使用中的車輛數量。使用者可透過地圖模式查詢臺北市各站點的即時資訊，包括可借車輛數、可還空位數及站點位置，方便即時掌握使用狀況，提升共享單車的使用效率與便利性。', '{https://tdx.transportdata.tw/api-service/swagger/basic/2cc9b888-a592-496f-99de-9ab35b7fb70d#/Bike/BikeApi_Availability_2181}', '{doit}', '2023-12-20 05:56:00+00', '2024-03-19 06:08:17.99+00', 'percent', 'select ''在站車輛'' as x_axis, 
unnest(ARRAY[''可借車輛'', ''空位'']) as y_axis, 
unnest(ARRAY[SUM(available_rent_general_bikes), SUM(available_return_bikes)]) as data
from tran_ubike_realtime', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('commercial_district_density', NULL, '{13}', '{}', 'static', NULL, NULL, NULL, '商業處', '顯示各行政區市集活動分佈', '此圖表呈現台北市各行政區的市集活動分佈，包括市集數量、展覽活動等指標。透過行政區視覺化，協助了解各區市集活動狀況，為商圈活化政策提供數據支撐。', '可用於市集活動政策制定、投資評估與區域發展規劃。適合政府部門評估市集發展潛力、投資者選址參考，以及商業顧問進行市場分析。', '{}', '{doit}', '2025-05-31 18:53:37.288175+00', '2025-05-31 18:53:37.288175+00', 'three_d', 'SELECT x_axis, y_axis, data FROM (VALUES 
        (''北投區'', ''商店數量'', 120),
        (''士林區'', ''商店數量'', 280),
        (''內湖區'', ''商店數量'', 220),
        (''南港區'', ''商店數量'', 150),
        (''松山區'', ''商店數量'', 320),
        (''信義區'', ''商店數量'', 380),
        (''中山區'', ''商店數量'', 450),
        (''大同區'', ''商店數量'', 180),
        (''中正區'', ''商店數量'', 290),
        (''萬華區'', ''商店數量'', 200),
        (''大安區'', ''商店數量'', 420),
        (''文山區'', ''商店數量'', 160),
        (''北投區'', ''平均營業額'', 85),
        (''士林區'', ''平均營業額'', 95),
        (''內湖區'', ''平均營業額'', 110),
        (''南港區'', ''平均營業額'', 88),
        (''松山區'', ''平均營業額'', 125),
        (''信義區'', ''平均營業額'', 150),
        (''中山區'', ''平均營業額'', 135),
        (''大同區'', ''平均營業額'', 75),
        (''中正區'', ''平均營業額'', 105),
        (''萬華區'', ''平均營業額'', 80),
        (''大安區'', ''平均營業額'', 140),
        (''文山區'', ''平均營業額'', 70)
    ) AS t(x_axis, y_axis, data)', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('commercial_district_ranking_metrotaipei', NULL, '{}', '{}', 'current', NULL, 0, 'minute', '商業處', '顯示雙北商圈綜合排行榜', '此組件展示雙北地區商圈的綜合排名，包含人流量、商店數量、平均營業額等多維度指標。透過即時數據更新，提供動態的商圈表現評估，協助商家和政策制定者掌握商圈發展趨勢。', '適用於商圈競爭力分析、投資決策參考、及商業地產評估。可幫助連鎖企業選址、政府制定商圈振興政策，以及消費者了解熱門商圈動態。', '{}', '{doit,ntpc}', '2025-05-31 18:54:10.801234+00', '2025-05-31 18:54:10.801234+00', 'three_d', 'SELECT x_axis, y_axis, data FROM (VALUES 
        (''信義商圈'', ''人流量'', 15000),
        (''西門町商圈'', ''人流量'', 12000),
        (''板橋商圈'', ''人流量'', 10000),
        (''東區商圈'', ''人流量'', 9500),
        (''中和環球商圈'', ''人流量'', 8800),
        (''天母商圈'', ''人流量'', 8500),
        (''三重商圈'', ''人流量'', 8200),
        (''士林夜市商圈'', ''人流量'', 8000),
        
        (''信義商圈'', ''商店數'', 450),
        (''西門町商圈'', ''商店數'', 380),
        (''板橋商圈'', ''商店數'', 320),
        (''東區商圈'', ''商店數'', 300),
        (''中和環球商圈'', ''商店數'', 280),
        (''天母商圈'', ''商店數'', 260),
        (''三重商圈'', ''商店數'', 240),
        (''士林夜市商圈'', ''商店數'', 220),
        
        (''信義商圈'', ''營業額'', 180),
        (''西門町商圈'', ''營業額'', 150),
        (''板橋商圈'', ''營業額'', 130),
        (''東區商圈'', ''營業額'', 145),
        (''中和環球商圈'', ''營業額'', 125),
        (''天母商圈'', ''營業額'', 135),
        (''三重商圈'', ''營業額'', 120),
        (''士林夜市商圈'', ''營業額'', 110)
    ) AS t(x_axis, y_axis, data)', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('commercial_district_density_metrotaipei', NULL, '{14}', '{}', 'static', NULL, NULL, NULL, '商業處', '顯示雙北各行政區市集活動分佈', '此圖表呈現台北市與新北市各行政區的市集活動分佈，包括市集數量、展覽活動等指標。透過雙北行政區視覺化比較，協助了解兩市市集活動差異，為跨市商圈活化政策提供數據支撐。', '可用於雙北市集活動政策制定、跨市投資評估與區域發展規劃。適合政府部門評估雙北市集發展潛力差異、投資者進行跨市選址比較，以及商業顧問進行雙北市場分析。', '{}', '{doit,ntpc}', '2025-05-31 18:54:10.799775+00', '2025-05-31 18:54:10.799775+00', 'three_d', 'SELECT x_axis, y_axis, data FROM (VALUES 
        -- 台北市各區
        (''北投區'', ''商店數量'', 120),
        (''士林區'', ''商店數量'', 280),
        (''內湖區'', ''商店數量'', 220),
        (''南港區'', ''商店數量'', 150),
        (''松山區'', ''商店數量'', 320),
        (''信義區'', ''商店數量'', 380),
        (''中山區'', ''商店數量'', 450),
        (''大同區'', ''商店數量'', 180),
        (''中正區'', ''商店數量'', 290),
        (''萬華區'', ''商店數量'', 200),
        (''大安區'', ''商店數量'', 420),
        (''文山區'', ''商店數量'', 160),
        -- 新北市主要區域
        (''板橋區'', ''商店數量'', 350),
        (''新莊區'', ''商店數量'', 280),
        (''中和區'', ''商店數量'', 250),
        (''永和區'', ''商店數量'', 200),
        (''土城區'', ''商店數量'', 180),
        (''樹林區'', ''商店數量'', 150),
        (''三重區'', ''商店數量'', 220),
        (''蘆洲區'', ''商店數量'', 160),
        (''五股區'', ''商店數量'', 120),
        (''泰山區'', ''商店數量'', 90),
        (''林口區'', ''商店數量'', 140),
        (''淡水區'', ''商店數量'', 180)
    ) AS t(x_axis, y_axis, data)', NULL, 'metrotaipei');
INSERT INTO public.query_charts VALUES ('commercial_district_density_metrotaipei', NULL, '{13}', '{}', 'static', NULL, NULL, NULL, '商業處', '顯示台北市各行政區市集活動分佈', '此圖表呈現台北市各行政區的市集活動分佈，包括市集數量、展覽活動等指標。透過行政區視覺化，協助了解各區市集活動狀況，為商圈活化政策提供數據支撐。', '可用於台北市市集活動政策制定、投資評估與區域發展規劃。適合政府部門評估市集發展潛力、投資者選址參考，以及商業顧問進行市場分析。', '{}', '{doit}', '2025-05-31 18:54:10.801009+00', '2025-05-31 18:54:10.801009+00', 'three_d', 'SELECT x_axis, y_axis, data FROM (VALUES 
        -- 台北市各區 (僅台北市資料)
        (''北投區'', ''商店數量'', 120),
        (''士林區'', ''商店數量'', 280),
        (''內湖區'', ''商店數量'', 220),
        (''南港區'', ''商店數量'', 150),
        (''松山區'', ''商店數量'', 320),
        (''信義區'', ''商店數量'', 380),
        (''中山區'', ''商店數量'', 450),
        (''大同區'', ''商店數量'', 180),
        (''中正區'', ''商店數量'', 290),
        (''萬華區'', ''商店數量'', 200),
        (''大安區'', ''商店數量'', 420),
        (''文山區'', ''商店數量'', 160),
        -- 台北市平均營業額指標
        (''北投區'', ''平均營業額'', 85),
        (''士林區'', ''平均營業額'', 95),
        (''內湖區'', ''平均營業額'', 110),
        (''南港區'', ''平均營業額'', 88),
        (''松山區'', ''平均營業額'', 125),
        (''信義區'', ''平均營業額'', 150),
        (''中山區'', ''平均營業額'', 135),
        (''大同區'', ''平均營業額'', 75),
        (''中正區'', ''平均營業額'', 105),
        (''萬華區'', ''平均營業額'', 80),
        (''大安區'', ''平均營業額'', 140),
        (''文山區'', ''平均營業額'', 70)
    ) AS t(x_axis, y_axis, data)', NULL, 'taipei');
INSERT INTO public.query_charts VALUES ('quiz_component', NULL, '{}', '{}', 'static', NULL, NULL, NULL, '台北市政府 x 心理學研究', '透過心理測驗，找到最適合你的台北商圈！', '這是一個互動式的心理測驗，通過分析你的消費習慣、喜好風格、活動偏好等因素，為你推薦最適合的台北商圈。測驗包含4個問題，根據你的答案會推薦1-3個符合你性格的商圈，並提供詳細的商圈資訊、交通指南、預算參考等實用資訊。', '適用於遊客規劃行程、在地人探索新商圈、商家了解目標客群。透過性格分析推薦機制，提升商圈媒合效率，增加使用者滿意度，促進商圈經濟活動。', '{https://github.com/tpe-doit/Taipei-City-Dashboard-FE}', '{doit}', '2025-06-01 00:05:36.872897+00', '2025-06-01 00:05:36.872897+00', 'three_d', 'SELECT 
        unnest(ARRAY[''個性化推薦'', ''測驗統計'', ''使用情況'']) AS x_axis,
        unnest(ARRAY[''心理測驗'', ''數據分析'', ''用戶體驗'']) AS y_axis,
        unnest(ARRAY[1, 1, 1]) AS data,
        ''psychology'' AS icon', NULL, 'taipei');


--
-- Name: component_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.component_maps_id_seq', 14, true);


--
-- Name: components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.components_id_seq', 61, true);


--
-- Name: contributors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.contributors_id_seq', 1, false);


--
-- Name: dashboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboards_id_seq', 382, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 4, true);


--
-- PostgreSQL database dump complete
--

