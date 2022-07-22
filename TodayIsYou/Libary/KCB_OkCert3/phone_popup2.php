<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=euc-kr">
<?php
	header('Content-Type: text/html; charset=euc-kr');
    //**************************************************************************
	// 파일명 : phone_popup2.php
	// - 팝업페이지
	// 휴대폰 본인확인 서비스 인증페이지 호출 화면
    //
    // ※주의
    // 	실제 운영시에는 화면에 보여지는 데이터를 삭제하여 주시기 바랍니다.
    // 	방문자에게 사이트데이터가 노출될 수 있습니다.
    //**************************************************************************
	
	/**************************************************************************
	 * okcert3 휴대폰 본인확인 서비스 파라미터
	 **************************************************************************/
	 
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' 회원사 사이트명, URL
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$SITE_NAME	=	$_REQUEST["SITE_NAME"];
	$SITE_URL 	=   "www.test.co.kr";
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' KCB로부터 부여받은 회원사코드(아이디) 설정 (12자리)
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$CP_CD = $_REQUEST["CP_CD"];
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    //' 리턴 URL 설정
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' opener(phone_popup1.php)의 도메일과 일치하도록 설정해야 함. 
	//' (http://www.test.co.kr과 http://test.co.kr는 다른 도메인으로 인식하며, http 및 https도 일치해야 함)
	$RETURN_URL = "http://".$_SERVER['HTTP_HOST']."/phone_popup/phone_popup3.php";// 인증 완료 후 리턴될 URL (도메인 포함 full path)
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' 인증요청사유코드 (가이드 문서 참조)
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$RQST_CAUS_CD ="00";
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' 채널 코드 (공백가능. 필요한 회원사에서만 입력)
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//$CHNL_CD	=	$_REQUEST["CHNL_CD"];	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//' 리턴메시지 (공백가능. returnUrl에서 같이 전달받고자 하는 값이 있다면 설정.)
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	//$RETURN_MSG = "";
	
	// ########################################################################
	// # 타겟 및 인증팝업URL : 운영/테스트 전환시 변경 필요
	// ########################################################################
	$target = "PROD";	// 테스트="TEST", 운영="PROD"
	//$popupUrl = "";	// 테스트 URL
	$popupUrl = "https://safe.ok-name.co.kr/CommonSvl";	// 운영 URL
	
	//'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
    //' 라이센스 파일
    //'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
	$license = "C:\\okcert3_license\\".$CP_CD."_IDS_01_".$target."_AES_license.dat";
	
	/**************************************************************************
	okcert3 request param JSON String
	**************************************************************************/
	$params  = '{ "CP_CD":"'.$CP_CD.'",';
	$params .= '"RETURN_URL":"'.$RETURN_URL.'",';
	$params .= '"SITE_NAME":"'.$SITE_NAME.'",';
	$params .= '"SITE_URL":"'.$SITE_URL.'",';
	
	//$params .= '"CHNL_CD":"'.$CHNL_CD.'",';
	//$params .= '"RETURN_MSG":"'.$RETURN_MSG.'",';

	//' 거래일련번호는 기본적으로 모듈 내에서 자동 채번되고 채번된 값을 리턴해줌.
	//'	회원사가 직접 채번하길 원하는 경우에만 아래 코드를 주석 해제 후 사용.
	//' 각 거래마다 중복 없는 $을 생성하여 입력. 최대길이:20바이트
	//$params .= '"TX_SEQ_NO":"'."123456789012345".'",'; 
	
	$params .= '"RQST_CAUS_CD":"'.$RQST_CAUS_CD.'" }';
	
	
	$svcName = "IDS_HS_POPUP_START";
	$out = NULL;
	
	// okcert3 실행
	//$ret = okcert3_u($target, $CP_CD, $svcName, $params, $license, $out);	// UTF-8
	$ret = okcert3($target, $CP_CD, $svcName, $params, $license, $out);		// EUC-KR
	
	/**************************************************************************
	okcert3 응답 정보
	**************************************************************************/
	$RSLT_CD = "";						// 결과코드
	$RSLT_MSG = "";						// 결과메시지
	$MDL_TKN = "";						// 모듈토큰
	$TX_SEQ_NO = "";					// 거래일련번호
	
	if ($ret == 0) {// 함수 실행 성공일 경우 변수를 결과에서 얻음
		$out = iconv("euckr","utf-8",$out);		// 인코딩 icnov 처리. okcert3 호출(EUC-KR)일 경우에만 사용 (json_decode가 UTF-8만 가능)
		$output = json_decode($out,true);		// $output = UTF-8
		
		$RSLT_CD = $output['RSLT_CD'];
		$RSLT_MSG  = iconv("utf-8","euckr", $output["RSLT_MSG"]);	// 다시 EUC-KR 로 변환
		
		if(isset($output["TX_SEQ_NO"])) $TX_SEQ_NO = $output["TX_SEQ_NO"]; // 필요 시 거래 일련 번호 에 대하여 DB저장 등의 처리
		
		if( $RSLT_CD == "B000" ) { // B000 : 정상건
			$MDL_TKN = $output['MDL_TKN']; 
		}
	}
	else {
		echo ("<script>alert('Fuction Fail / ret: ".$ret."'); self.close();</script>");
	}
?>
<title>KCB 휴대폰 본인확인 서비스 샘플 2</title>
<script>
	function request(){
		document.form1.action = "<?=$popupUrl?>";
		document.form1.method = "post";

		document.form1.submit();
	}
</script>
</head>

<body>
	<form name="form1">
	<!-- 인증 요청 정보 -->
	<!--// 필수 항목 -->
	<input type="hidden" name="tc" value="kcb.oknm.online.safehscert.popup.cmd.P931_CertChoiceCmd"/>		<!-- 변경불가-->
	<input type="hidden" name="cp_cd" value="<?=$CP_CD?>">	<!-- 회원사코드 -->
	<input type="hidden" name="mdl_tkn" value="<?=$MDL_TKN?>">	<!-- 모듈토큰 --> 
	<input type="hidden" name="target_id" value="">	
	<!-- 필수 항목 //-->	
	</form>
<?php
 	if ($RSLT_CD == "B000") {
		//인증요청
		echo ("<script>request();</script>");
	} else {
		//요청 실패 페이지로 리턴
		echo ("<script>alert('".$RSLT_CD." : ".$RSLT_MSG."'); self.close();</script>");
	}
?>
</body>
</html>
