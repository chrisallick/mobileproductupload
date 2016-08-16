$(window).load(function(){
	$("#wrapper").animate({
		opacity: 1
	});
});

$(document).ready(function() {
	$(".product").click(function(){
		window.location = "http://localhost:9299/product/" + $(this).data("pid");
	})
});