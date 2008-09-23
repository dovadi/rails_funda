var ieVer = navigator.userAgent.match(/MSIE (\d+\.\d+)/);
//var IE6 = (navigator.userAgent.indexOf("MSIE 6")>=0) ? true : false;
var IE6 = parseFloat(ieVer[1]) < 7;
if(IE6){

	$(function(){
		
		var s = $("<div>")
			.css({
				'position': 'absolute',
				'top': '0px',
				'left': '0px',
				backgroundColor: 'black',
        'filter' :'alpha(opacity=50)',
				'opacity': '0.75',
				'width': '100%',
				'height': $(window).height(),
				zIndex: 5000
			})
			.appendTo(document.body);
		$("<div><img src='/images/no-ie6.png' alt='' style='float: left;'/><p><br /><strong>Sorry! This page doesn't support Internet Explorer 6.</strong><br /><br />If you'd like to read our content please <a href='http://getfirefox.com'>upgrade your browser</a>.</p>")
			.css({
				backgroundColor: 'white',
				'left': '50%',
				marginLeft: -210,
				marginTop: -100,
				width: 410,
				paddingRight: 10,
				height: 200,
				'position': 'absolute',
				zIndex: 6000
			})
			.appendTo(document.body);
	});		
}