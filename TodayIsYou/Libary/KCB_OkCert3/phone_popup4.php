<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// 파일명 : phone_popup4.php
	// - 바닥페이지
	// 휴대폰 본인확인 서비스 결과 완료 화면
	//**************************************************************************
	$CP_CD				= $_REQUEST["CP_CD"];			// 회원사코드
	$TX_SEQ_NO			= $_REQUEST["TX_SEQ_NO"];		// 거래번호
	$RSLT_CD			= $_REQUEST["RSLT_CD"];		// 결과코드
	$RSLT_MSG			= $_REQUEST["RSLT_MSG"];		// 결과메세지
	
	$RSLT_NAME			= $_REQUEST["RSLT_NAME"];		// 성명
	$RSLT_BIRTHDAY		= $_REQUEST["RSLT_BIRTHDAY"];	// 생년월일
	$RSLT_SEX_CD		= $_REQUEST["RSLT_SEX_CD"];	// 성별
	$RSLT_NTV_FRNR_CD	= $_REQUEST["RSLT_NTV_FRNR_CD"];// 내외국인구분
	
	$DI					= $_REQUEST["DI"];				// DI
	$CI					= $_REQUEST["CI"];				// CI
	$CI_UPDATE			= $_REQUEST["CI_UPDATE"];		// CI 업데이트
	$TEL_COM_CD			= $_REQUEST["TEL_COM_CD"];		// 통신사코드
	$TEL_NO				= $_REQUEST["TEL_NO"];			// 휴대폰번호
	
	$RETURN_MSG			= $_REQUEST["RETURN_MSG"];		// 리턴메시지
	
?>
<title>KCB 휴대폰 본인확인 서비스 샘플 4</title>
</head>
<body>
<h3>인증결과</h3>
<ul>
  <li>회원사코드	: <?=$CP_CD?> </li>
  <li>거래번호		: <?=$TX_SEQ_NO?> </li>
  <li>결과코드		: <?=$RSLT_CD?></li>
  <li>결과메세지	: <?=$RSLT_MSG?></li>
 
  <li>성명			: <?=$RSLT_NAME?> </li>
  <li>생년월일		: <?=$RSLT_BIRTHDAY?> </li>
  <li>성별			: <?=$RSLT_SEX_CD?> </li>
  <li>내외국인구분	: <?=$RSLT_NTV_FRNR_CD?> </li>
  
  <li>DI			: <?=$DI?> </li>
  <li>CI			: <?=$CI?> </li>
  <li>CI업데이트	: <?=$CI_UPDATE?> </li>
  <li>통신사코드	: <?=$TEL_COM_CD?> </li>
  <li>휴대폰번호	: <?=$TEL_NO?> </li>
  
  <li>리턴메시지	: <?=$RETURN_MSG?> </li>

</ul>

<br/>
* 성별 - M:남, F:여
<br/>
* 내외국인구분 - L:내국인, F:외국인
<br/>
* 통신사 - 01:SKT, 02:KT, 03:LGU+, 04:SKT알뜰폰, 05:KT알뜰폰, 06:LGU+알뜰폰
</body>
</html>
