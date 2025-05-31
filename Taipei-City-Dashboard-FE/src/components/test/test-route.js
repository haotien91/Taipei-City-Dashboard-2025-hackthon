// 將此路由添加到 router/index.js

{
  path: '/test/commercial-map',
  name: 'commercial-map-test',
  component: () => import('@/components/test/CommercialDistrictMap.vue'),
  meta: {
    title: '商圈活化地圖測試'
  }
}
