export const Global = Object.freeze({
/*general*/
    BASE_IGV :0.18,
    BASE_API_SUNAT :'https://dniruc.apisperu.com/api/v1/',
    TOKEN_API_PERU:'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6InZ0b3Jlcm9AZ21haWwuY29tIn0.j-kQo0Dz4mb9wH3NjeXcurSu0MpBWfqt-AODCMKzpjM',
    DOWNLOAD_CDR:'http://35.231.78.51/fapi/demo/examples/pages/status.php',


/*produccion*/
//BASE_API_URL :'http://35.231.78.51/fapi/' ,
//RUC_EMPRESA:'20605174095',
//TOKEN_FACTURACION:'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTAxNzI4ODYsInVzZXJuYW1lIjoidnRvcmVybyIsImNvbXBhbnkiOiIyMDYwNTE3NDA5NSIsImV4cCI6NDc2Mzc3Mjg4Nn0.nL93zWcOm8w3ZAkWm_Ia9vF7DaFnP_wzuSgeF7_X1CvzvQOotSK12WphLo7jFmBRfLJm2UBPoUucOSNzbk3zdbvjCdG1p2tQ7CQlypxWggSxQ76Wma6cFJL7NF9ULxOQEWGm3b2CVVfDq2MgSyE6xNmOGuzP_7CsSyukd-Q8MOqjgtefBRPeN0XtX85s0Ie-5Twy_AP-MXOFj1gYapEpSPWN4QrK4wibAu8tVs01ipczGsZXzrQWZFVpmozluXPtsx6hNHy_XAGhJSIU1Ftj8rc5xIa7RD2-VO-nJVlChmTPB5TGNH4YsQOASAaGXBtZmqxtpK9RJAmSFPpvxBr3XC6bcBGBRPUy0CmcH6VeVPJNTRcNzP7H11hFi49iS8P04ViccR8kMnUd-ABIGRSuhdxy6yv3JjV6P9MuyjSFmJFi1Mlw8lGFLI9UeHxLAr1AXk0MvD1-MtFMrHWc0JrqeiW8EU9RbwGAxGdVxCM9bVinQ6fYzou6W9lcjnHbktR3VqLiI6kkJlOIYRzByHLmOX59BlPhTcqJTC-jGKsuR7rJfMljKmknzDhnKy3eD16FShpzzpEXtta5tf_RvF4sMeX6XTT2WSN2z6RbtGvTyJ9bG3COpv7_iByUpHXh8VJTF5nzloKwS_lj7w45PP0_Rb7Al31POnfFOarU8dRM9LA',

//Desarrollo*/
BASE_API_URL :'http://35.231.78.51/fapi-dev/' ,
RUC_EMPRESA:'20521048825',
TOKEN_FACTURACION:'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MjE5OTc5NjQsImV4cCI6NDc3NTU5Nzk2NCwidXNlcm5hbWUiOiJ2dG9yZXJvIiwiY29tcGFueSI6IjIwNTIxMDQ4ODI1In0.bHutFGMZAqODBqfJnlSQNMuonyC3d5elHpy1wIXRwB3QtIPk7y3rnELjk1JBZF7G54vy5AsyJQPSpRLGs8Llo1QUC2g0yC83LBI1QGhpZ5W85PyPnTqldUoYTtXMvmChlz9CnExb-5sReOPTFlhy2IgUSpNdYIXC5G3YUZ32XgkRiiRWytS1swMQ-Nk52CBzzwH34oD6JwjMUS71T7_949CgsCyHZq5mSclXdGsIq6jfqi1JBo0na3OY0KmSpuJfsSmomJrbeqZauPLg50obAE029sgdjD7uW739aPNh1MP-_ZETa9b36gFcDQ_q3gytfVMissnLjNl1r92efY_WQ4wewa897hRPDm6i7XbRCkILPiYiWDxQ3tNsQIvg1Kg9Gu-090jdcdo5Mwx2mD4KGugPsYzfbmxCBUIRciFIaNiKnNFzQyELu7N0ghWJ6d-2vV1hQLEaZJPScqvVQbcJWwqawZEJ7cPLnlDXS2z-s59RtcMlH3gkVT9aT5df6oOe4yJzOpEa_zoPnumFwKHGVO5G0m2gzsNfEjz7B-zLa32lTxjPEUBUgFnuh7Xdoo88PHmKgAZ_JhxpU-Tq7dM3_dMZJwBigw_kLO1n3SI6ozPiPkBOQ0_un2ZP3dVRZ1ABfCjp2KK8NF0FIJAkLk-alrGCwNT4HgprxMnV0DmQyQU',
//TOKEN_API_PERU_BEARER:'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MTAxNzE0ODcsImV4cCI6MTYxMDI1Nzg4Nywicm9sZXMiOlsiUk9MRV9VU0VSIl0sInVzZXJuYW1lIjoidnRvcmVybyJ9.poxBjVG7Pe46TU3aX8VOKOJMlOe2V6hb3q1IcrAe8uut_naAFQIcyAWSWSNEF3071dOHc_Riv8OGgbIwUMtTQOQQV5UzVSLkXhiKVgAY-b9Uo4HhjVkdT60W-YAeRY91b5sL83hk-ItKLwenUUtxmg9QU4WjYv2zzb7HXt7WCuLVcgXmRHX5R9eXETlhMg75WJIeXYhXBdRRxois9avMneJ9f7l_vX_NKI1LVX6IXxq8towxk-crTs2QRqp7okHgKRrGQ8j0DPI_-6woC-0hbTobGVuSrVpJLDpnrqxKYyprhFPWwSxZl3XqmtMpz_g6BlZdu_ddz9o-I8CBCgteDYJrqYgF6os-t4-Pyk9SfiRe0LGamf_Csl4Vtznh0BfQ77nvRNlzG64do8hoMF3-gkZjIkKIbXAksS-1RhkC1IPVXOcxchieVX-uN4uxOv95MZ85_yRqc9NKt8ghRnggP9bYauswvdLzAOKDe59KtBPWAAr1lVLBxoSRPKkLsq4DEnypGGl9CdAVXWanMkGNCk61mJE6DuIK2KIN5evejV83oexwA45eB_CRY8cbuS0zIc_9ywTbHUtd7_xL9L7IMd_w_oS8VZZxIKUYoICIdkGcthoROhE_zNah7tgB7DQGudT1lvbyGmS8IpzZ94K8_KQKtJw7Z3kO2GidHDhoj_A',
});
