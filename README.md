# TodayIsYou
#### 이앱은 화상채팅, 채팅, 앱니디다.
#### 주요기술 GoogleWebRTC를 이용한 화상채팅, 음성채팅을 구현하다.


<script type="text/javascript" src="/path/to/jquery-1.10.1.min.js"></script>
<script type="text/javascript" src="/path/to/jquery.videoController.min.js"></script>
### 화상채팅
<body>
	<iframe id="my-video" src="https://github.com/iruri2010/TodayIsYou/blob/master/video.mp4" width="270" height="480" frameborder="0" allowfullscreen></iframe>
  <div class="controls">
	    <a href="#" onclick="playVideo();">Play</a>
	    <a href="#" onclick="pauseVideo();">Pause</a>
	    <a href="#" onclick="stopVideo();">Stop</a>
	</div>
</body>
<script type="text/javascript">
	$(document).ready(function() {
		$('#my-video').videoController();
	});
</script>


### 앱스크린샷
<table>
<tr>
  <td>권한설정</td>
  <td>리스트</td>
  <td>채팅</td>
</tr>
<tr>
  <td><img src="https://github.com/iruri2010/TodayIsYou/blob/master/permission.PNG" width=270, height=480></td>
  <td><img src="https://github.com/iruri2010/TodayIsYou/blob/master/imagetalk.PNG" width=270, height=480></td>
  <td><img src="https://github.com/iruri2010/TodayIsYou/blob/master/chatting.PNG" width=270, height=480></td>
</tr>
<tr>
  <td>포인트 충전</td> 
  <td>영상채팅</td>
</tr>
<tr>
  <td><img src="https://github.com/iruri2010/TodayIsYou/blob/master/purchase.PNG" width=270, height=480></td>
  <td><img src="https://github.com/iruri2010/TodayIsYou/blob/master/webrtc.PNG" width=270, height=480></td>
</tr>
<table>
