$(window).load(function(){
	$("#wrapper").animate({
		opacity: 1
	});
});

$(document).ready(function() {
	$(".product").click(function(){
		window.location = window.location.origin + "/product/" + $(this).data("pid");
	})
});