#include <a_samp>
#include "../include/gl_common.inc"

public OnFilterScriptInit()
{
	//============================Vehicles====================================//

	//========================Banshees (Spawn)================================//
	AddStaticVehicleEx(429,1244.5918,-2044.0123,59.4385,269.5728,3,8,30);
	AddStaticVehicleEx(429,1244.4556,-2039.0112,59.4530,269.5737,3,8,30);
	AddStaticVehicleEx(429,1244.3218,-2034.0103,59.4569,269.5735,3,8,30);
	AddStaticVehicleEx(429,1244.1880,-2029.0093,59.4598,269.5735,3,8,30);
	AddStaticVehicleEx(429,1244.0435,-2024.0083,59.5090,269.5708,3,8,30);
	AddStaticVehicleEx(429,1244.4020,-2019.0110,59.4543,269.5735,3,8,30);
	AddStaticVehicleEx(429,1244.2681,-2014.0100,59.4581,269.5736,3,8,30);
	AddStaticVehicleEx(429,1244.1344,-2009.0090,59.4586,269.5736,3,8,30);
	
	//========================Infernus's (Spawn)==============================//
	AddStaticVehicleEx(562,1277.2325,-2008.8496,58.6537,90.9820,80,1,30);
	AddStaticVehicleEx(562,1277.2898,-2013.8459,58.6799,90.9880,80,1,30);
	AddStaticVehicleEx(562,1277.3527,-2018.8459,58.6532,90.9999,80,1,30);
	AddStaticVehicleEx(562,1277.1606,-2023.8486,58.6727,91.0445,80,1,30);
	AddStaticVehicleEx(562,1277.2394,-2028.8505,58.6903,91.0443,80,1,30);
	AddStaticVehicleEx(562,1277.3176,-2033.8517,58.7078,91.0446,80,1,30);
	AddStaticVehicleEx(562,1277.5691,-2038.5188,58.7298,89.9342,80,1,30);
	AddStaticVehicleEx(562,1277.5576,-2043.5189,58.7753,89.9388,80,1,30);
	
	//========================Drifts Vehicles=================================//
	AddStaticVehicleEx(411,-314.8287,1514.7446,75.0528,1.3532,64,1,30);             // Infernus - Drift1//
	AddStaticVehicleEx(411,-317.7801,1515.4036,75.0402,0.2407,64,1,30);             // Infernus - Drift1//
	AddStaticVehicleEx(562,-321.1545,1515.1018,75.0316,1.0602,36,1,30);             // Elegy - Drift1//
	AddStaticVehicleEx(562,-324.1783,1515.1737,75.0190,359.2409,36,1,30);           // Elegy - Drift1//
	AddStaticVehicleEx(603,-327.2997,1514.8605,75.2209,0.4270,32,1,30);             // Phoenix - Drift1//
	AddStaticVehicleEx(603,-330.2702,1515.1918,75.1976,0.0379,32,1,30);             // Phoenix - Drift1//
	AddStaticVehicleEx(451,-333.5902,1515.0868,75.0659,358.1462,36,36,30);          // Turismo - Drift1//
	AddStaticVehicleEx(451,-336.5558,1515.6045,75.0652,359.4702,36,36,30);          // Turismo - Drift1//
	AddStaticVehicleEx(602,-339.7686,1515.3315,75.0475,359.4720,69,1,30);           // Alpha - Drift1//
	AddStaticVehicleEx(602,-342.9582,1515.2747,75.0470,0.7727,69,1,30);             // Alpha - Drift1
	AddStaticVehicleEx(602,-1040.8020,-1350.3877,130.0764,104.3700,69,1,30);        // Alpha - Drift4//
	AddStaticVehicleEx(429,-1045.5331,-1348.4998,129.9614,97.8369,13,13,30);        // Banshee - Drift4//
	AddStaticVehicleEx(562,-1048.5942,-1345.7634,129.9555,98.7577,17,1,30);         // Elegy - Drift4//
	AddStaticVehicleEx(411,1091.6051,2298.4656,10.5255,269.1693,123,1,30);          // Infernus - Drift 6//
	AddStaticVehicleEx(411,1091.4738,2288.5093,10.5334,269.1803,123,1,30);          // Infernus - Drift 6//
	AddStaticVehicleEx(451,1084.8191,2288.6338,10.4702,268.4966,61,61,30);          // Turismo - Drift 6//
	AddStaticVehicleEx(451,1085.0681,2298.5449,10.4603,268.4279,61,61,30);          // Turismo - Drift 6//
	AddStaticVehicleEx(451,-784.5894,2752.4451,45.3542,272.8446,61,61,30);          // Turismo - Drift 7//
	
	//=============================Pickups====================================//
	AddStaticPickup(1239, 1, 1222.5375,-2036.8712,65.2266); //Spawn PickUp

	//=============================Objects====================================//
	
	//=========================Drifting School================================//
	CreateObject(3573, 1148.141846, 1354.434814, 12.512004, 0.0000, 0.0000, 95.2340);
	CreateObject(3574, 1145.118652, 1337.235474, 12.512004, 0.0000, 0.0000, 56.2500);
	CreateObject(3574, 1126.693115, 1341.763794, 12.512004, 0.0000, 0.0000, 56.2500);
	CreateObject(3575, 1141.132080, 1326.990356, 12.512003, 0.0000, 0.0000, 180.0000);
	CreateObject(3575, 1117.468872, 1326.732788, 12.512003, 0.0000, 0.0000, 348.7500);
	CreateObject(3578, 1132.182617, 1307.735107, 10.598346, 0.0000, 0.0000, 337.5000);
	CreateObject(3578, 1141.824097, 1305.810181, 10.598346, 0.0000, 0.0000, 0.0000);
	CreateObject(3578, 1123.779419, 1313.590454, 10.598346, 0.0000, 0.0000, 315.0000);
	CreateObject(3578, 1150.192871, 1308.892822, 10.598346, 0.0000, 0.0000, 45.0000);
	CreateObject(3578, 1154.544922, 1317.181274, 10.598346, 0.0000, 0.0000, 78.7500);
	CreateObject(3578, 1157.393188, 1326.372070, 10.598347, 0.0000, 0.0000, 67.5000);
	CreateObject(3578, 1162.236816, 1327.180420, 10.590550, 0.0000, 0.0000, 303.7500);
	CreateObject(1282, 1153.315796, 1339.989868, 10.509129, 0.0000, 0.0000, 112.5001);
	CreateObject(1282, 1155.634033, 1341.942261, 10.509129, 0.0000, 0.0000, 101.2501);
	CreateObject(1237, 1159.016479, 1344.233521, 9.815398, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1172.374634, 1342.679565, 10.652738, 0.0000, 0.0000, 135.0000);
	CreateObject(3578, 1164.682129, 1317.903442, 10.598346, 0.0000, 0.0000, 270.0000);
	CreateObject(3578, 1164.692993, 1308.089111, 10.598346, 0.0000, 0.0000, 270.0000);
	CreateObject(3578, 1164.654663, 1298.191772, 10.598346, 0.0000, 0.0000, 270.0000);
	CreateObject(978, 1173.542847, 1282.183105, 10.660532, 0.0000, 0.0000, 45.0000);
	CreateObject(978, 1166.181030, 1278.876343, 10.660533, 0.0000, 0.0000, 0.0000);
	CreateObject(978, 1158.304199, 1281.250977, 10.660534, 0.0000, 0.0000, 326.2500);
	CreateObject(978, 1153.139526, 1287.516846, 10.660533, 0.0000, 0.0000, 292.5000);
	CreateObject(979, 1161.178711, 1299.317871, 10.660533, 0.0000, 0.0000, 135.0000);
	CreateObject(3578, 1146.444336, 1290.863770, 10.598346, 0.0000, 0.0000, 11.2500);
	CreateObject(3578, 1144.565918, 1302.082642, 10.598346, 0.0000, 0.0000, 11.2500);
	CreateObject(3578, 1135.526001, 1298.383545, 10.598346, 0.0000, 0.0000, 33.7500);
	CreateObject(3578, 1129.598389, 1291.022095, 10.598346, 0.0000, 0.0000, 67.5000);
	CreateObject(3578, 1128.890259, 1281.744873, 10.598344, 0.0000, 0.0000, 101.2500);
	CreateObject(3578, 1134.023926, 1274.335327, 10.598346, 0.0000, 0.0000, 146.2499);
	CreateObject(3578, 1141.153198, 1269.433228, 10.598346, 0.0000, 0.0000, 146.2499);
	CreateObject(3578, 1144.310059, 1285.884155, 10.598346, 0.0000, 0.0000, 123.7499);
	CreateObject(3578, 1150.293335, 1278.390747, 10.598346, 0.0000, 0.0000, 135.0000);
	CreateObject(3578, 1155.503174, 1270.791626, 10.598346, 0.0000, 0.0000, 112.4999);
	CreateObject(3578, 1142.786865, 1263.169067, 10.598346, 0.0000, 0.0000, 56.2500);
	CreateObject(3578, 1156.429443, 1261.270752, 10.598346, 0.0000, 0.0000, 78.7500);
	CreateObject(3578, 1152.860596, 1253.687134, 10.598346, 0.0000, 0.0000, 56.2500);
	CreateObject(3578, 1146.208130, 1246.929565, 10.598346, 0.0000, 0.0000, 35.3142);
	CreateObject(3578, 1138.171021, 1244.877075, 10.598347, 0.0000, 0.0000, 1.5642);
	CreateObject(3578, 1129.386353, 1247.190918, 10.598345, 0.0000, 0.0000, 327.8142);
	CreateObject(3578, 1138.995972, 1265.024414, 10.598345, 0.0000, 0.0000, 282.8142);
	CreateObject(3578, 1123.929077, 1254.857178, 10.598346, 0.0000, 0.0000, 282.8142);
	CreateObject(3578, 1119.687988, 1262.935303, 10.598346, 0.0000, 0.0000, 316.5642);
	CreateObject(3578, 1112.452271, 1267.419678, 10.598346, 0.0000, 0.0000, 339.0642);
	CreateObject(3578, 1126.298584, 1277.811523, 10.598346, 0.0000, 0.0000, 339.0642);
	CreateObject(3578, 1105.630371, 1273.324951, 10.598346, 0.0000, 0.0000, 294.0642);
	CreateObject(3578, 1104.660522, 1282.711792, 10.598346, 0.0000, 0.0000, 260.3142);
	CreateObject(3578, 1123.289429, 1278.935303, 10.636377, 0.0000, 0.0000, 339.0642);
	CreateObject(3578, 1123.084961, 1283.654541, 10.598346, 0.0000, 0.0000, 35.3142);
	CreateObject(3578, 1109.487427, 1290.143066, 10.598346, 0.0000, 0.0000, 35.3142);
	CreateObject(3578, 1113.502075, 1297.728394, 10.598346, 0.0000, 0.0000, 91.5642);
	CreateObject(979, 1153.617065, 1302.536499, 10.660533, 0.0000, 0.0000, 180.0000);
	CreateObject(979, 1130.906738, 1301.109375, 10.660533, 0.0000, 0.0000, 90.0001);
	CreateObject(3578, 1109.803589, 1306.917114, 10.598346, 0.0000, 0.0000, 136.5641);
	CreateObject(3578, 1103.049072, 1314.833496, 10.598346, 0.0000, 0.0000, 125.3142);
	CreateObject(3578, 1100.309082, 1323.549561, 10.598346, 0.0000, 0.0000, 91.5642);
	CreateObject(3578, 1099.261841, 1332.560425, 10.598346, 0.0000, 0.0000, 102.8142);
	CreateObject(3578, 1112.948364, 1337.226318, 10.598346, 0.0000, 0.0000, 102.8142);
	CreateObject(3578, 1099.934692, 1349.516602, 10.598346, 0.0000, 0.0000, 69.0642);
	CreateObject(3578, 1105.689331, 1358.560059, 10.598346, 0.0000, 0.0000, 46.5642);
	CreateObject(3578, 1115.739624, 1344.755981, 10.598346, 0.0000, 0.0000, 35.3142);
	CreateObject(3578, 1114.483154, 1362.004761, 10.758780, 0.0000, 0.0000, 1.5642);
	CreateObject(3578, 1124.988037, 1349.213013, 10.598346, 0.0000, 0.0000, 17.2660);

	//================================Sky Drift===============================//
	CreateObject(3991, 1109.789063, 1597.797607, 50.603775, 0.0000, 0.0000, 0.0000);
	CreateObject(3990, 1095.590942, 1716.325439, 51.110493, 0.0000, 0.0000, 0.0000);
	CreateObject(981, 1112.553711, 1657.236206, 53.117283, 0.0000, 0.0000, 303.7500);
	CreateObject(982, 1113.352661, 1659.587524, 52.860260, 0.0000, 0.0000, 33.7500);
	CreateObject(972, 1116.039551, 1664.244629, 52.195198, 0.0000, 0.0000, 213.7500);
	CreateObject(973, 1101.205811, 1718.434937, 52.872589, 0.0000, 0.0000, 123.7501);
	CreateObject(973, 1095.160400, 1724.952393, 52.872589, 0.0000, 0.0000, 146.2501);
	CreateObject(973, 1086.906616, 1726.982910, 52.802914, 0.0000, 0.0000, 191.2501);
	CreateObject(973, 1078.493774, 1724.088501, 52.734459, 0.0000, 0.0000, 213.7501);
	CreateObject(973, 1071.638672, 1718.341919, 52.931835, 0.0000, 0.0000, 225.0001);
	CreateObject(4127, 1046.736938, 1640.091675, 53.667286, 0.0000, 359.1406, 33.7500);
	CreateObject(1425, 1048.088135, 1647.243652, 54.172428, 0.0000, 0.0000, 180.0000);
	CreateObject(981, 1044.237305, 1645.372192, 54.677464, 0.0000, 0.0000, 191.2501);
	CreateObject(982, 1045.623657, 1643.187256, 54.577511, 0.0000, 0.0000, 281.2500);
	CreateObject(4131, 956.040527, 1606.982300, 50.796364, 0.0000, 0.0000, 279.5311);
	CreateObject(4203, 930.080078, 1532.016968, 40.667942, 7.7349, 359.1406, 348.8273);
	CreateObject(979, 934.683594, 1573.697144, 44.031925, 0.0000, 0.0000, 292.5000);
	CreateObject(978, 949.476868, 1570.235474, 44.162727, 0.0000, 0.0000, 33.7500);
	CreateObject(4127, 895.280701, 1472.848145, 34.272793, 0.0000, 0.0000, 270.0000);
	CreateObject(973, 908.669189, 1490.742188, 33.663906, 0.0000, 0.0000, 212.1083);
	CreateObject(973, 924.933472, 1486.569702, 33.593800, 0.0000, 0.0000, 110.8583);
	CreateObject(981, 904.725037, 1466.843750, 35.011669, 0.0000, 0.0000, 90.0000);
	CreateObject(982, 902.773560, 1467.722046, 34.840942, 0.0000, 0.0000, 0.0000);
	CreateObject(979, 906.578125, 1450.273438, 35.012272, 0.0000, 0.0000, 281.2500);
	CreateObject(4855, 867.775696, 1334.728394, 38.857849, 0.0000, 0.0000, 11.2500);
	CreateObject(4831, 725.742065, 1132.509644, 45.701412, 0.0000, 0.0000, 191.2501);
	CreateObject(972, 790.624939, 1247.542847, 41.820038, 0.0000, 0.0000, 281.2500);
	CreateObject(972, 795.476318, 1226.921875, 41.820038, 0.0000, 0.0000, 101.2500);
	CreateObject(1324, 807.640381, 1234.069458, 43.307533, 0.0000, 0.0000, 11.2500);
	CreateObject(1323, 806.977905, 1235.589600, 43.307533, 0.0000, 0.0000, 0.0000);
	CreateObject(982, 639.083618, 1208.841431, 42.506714, 0.0000, 0.0000, 315.0000);
	CreateObject(982, 626.875244, 1186.744507, 42.506714, 0.0000, 0.0000, 348.7500);
	CreateObject(982, 652.815369, 1048.750977, 42.334839, 0.0000, 0.0000, 33.7500);
	CreateObject(982, 670.159668, 1031.434814, 42.533405, 0.0000, 0.0000, 67.5000);
	CreateObject(4864, 904.358154, 1074.378906, 43.380859, 0.0000, 0.0000, 191.2501);
	CreateObject(972, 815.927734, 1070.023438, 41.846733, 0.0000, 2.5783, 282.0321);
	CreateObject(972, 824.854065, 1045.469116, 41.674858, 0.0000, 2.5783, 102.0321);
	CreateObject(972, 846.667786, 1042.602539, 41.674858, 0.0000, 2.5783, 68.2821);
	CreateObject(972, 837.226135, 1077.251221, 41.846733, 0.0000, 0.8594, 296.7972);
	CreateObject(976, 836.905884, 1051.718994, 41.761745, 90.2409, 3.4377, 0.0000);
	CreateObject(976, 832.035156, 1073.265625, 41.751015, 90.2409, 3.4377, 0.0000);
	CreateObject(979, 836.509766, 1062.050659, 42.518196, 0.0000, 0.0000, 22.5000);
	CreateObject(978, 836.898926, 1059.617188, 42.518196, 0.0000, 0.0000, 180.0000);
	CreateObject(5004, 983.535034, 1082.260010, 34.028210, 0.0000, 0.0000, 0.0000);
	CreateObject(3578, 967.622925, 1101.048340, 35.445824, 0.0000, 0.0000, 0.0000);
	CreateObject(3578, 976.606934, 1098.890869, 35.445824, 0.0000, 0.0000, 326.2500);
	CreateObject(3578, 982.452271, 1091.568848, 35.445824, 0.0000, 0.0000, 292.5000);
	CreateObject(3578, 983.377197, 1082.697998, 35.445824, 0.0000, 0.0000, 247.5000);
	CreateObject(3578, 976.943298, 1076.321777, 35.040619, 0.0000, 0.0000, 202.5000);
	CreateObject(3578, 968.300354, 1072.739014, 34.958874, 0.0000, 0.0000, 202.5000);
	CreateObject(972, 1101.954224, 1517.139160, 50.301376, 0.0000, 0.0000, 33.7500);
	CreateObject(972, 1129.848145, 1521.307861, 50.804504, 0.0000, 0.0000, 146.2500);
	CreateObject(971, 1114.689087, 1504.784912, 49.833893, 85.9437, 0.8594, 0.0000);
	CreateObject(973, 1110.422363, 1506.069336, 51.278603, 0.0000, 0.0000, 270.0000);
	CreateObject(973, 1119.179565, 1506.349609, 51.294304, 0.0000, 0.0000, 90.0000);
	CreateObject(973, 1114.671021, 1500.984741, 51.083069, 0.0000, 0.0000, 0.8594);
	return 1;
}