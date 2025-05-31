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
INSERT INTO public.components VALUES (219, 'commercial_district_flow', '商圈人流分析');
INSERT INTO public.components VALUES (220, 'commercial_district_density', '市集活動分佈');
INSERT INTO public.components VALUES (221, 'commercial_district_flow_metrotaipei', '雙北商圈人流分析');
INSERT INTO public.components VALUES (222, 'commercial_district_density_metrotaipei', '雙北商圈密度分布');
INSERT INTO public.components VALUES (61, 'commercial_district_ranking_metrotaipei', '雙北商圈排行榜');


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
INSERT INTO public.dashboards VALUES (361, 'commercial_district', '商圈活化', '{219,220}', 'store', '2025-05-31 18:53:37.261191+00', '2025-05-31 07:03:13.698496+00');
INSERT INTO public.dashboards VALUES (363, 'commercial_district_metrotaipei', '商圈活化', '{221,222,61}', 'store', '2025-05-31 18:54:10.771376+00', '2025-05-31 07:21:58.257472+00');


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
-- Name: component_maps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.component_maps_id_seq', 14, true);


--
-- Name: components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.components_id_seq', 61, true);


--
-- Name: dashboards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboards_id_seq', 380, true);


--
-- PostgreSQL database dump complete
--

