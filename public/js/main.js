function uploadimage(image) {
	var dataobj = {
		image: image.replace(/^data:image\/(png|jpeg|gif);base64,/, ""),
		title: $(".option.producttitle input").val(),
		cost: $(".option.productcost input").val(),
		quantity: $(".option.productquantity input").val()
	}

    $.ajax({
        type: 'POST',
        url: '/upload/',
        dataType: "json",
        data: dataobj,
        success: function(resp) {
        	if( resp && resp.s3_url && resp.gid ) {
        		console.log( resp );

        		$(".buttons, #options").hide();
        		$("#makegif").hide();
				$("#startover").show();

				var product_url = "http://localhost:9299/product/" + resp.gid
				$("#productlink a").attr("href", product_url);

				$("#productlink").show();
				$("#allproducts").show();
				
				$("#loading").hide();
        	}
        }
    });
}

function handleFile(file) {
    var reader = new FileReader();
    reader.onload = function (event) {
        var dataURL = event.target.result;

        face.onload = function() {
			if( this.width < this.height || this.width == this.height ) {
				var scaler = (canvas.width / this.width);
				this.width = this.width * scaler;
				this.height = this.height * scaler;
			} else {
				var scaler = (canvas.height / this.height);
				this.height = this.height * scaler;
				this.width = this.width * scaler;
			}

			var x = (290 - (this.width/2));
			$(this).css({
				left: x
			});

			this.className = "person";

			$("#dealwithit .overlay").append( this );
			$("#makegif").removeClass("inactive");
        }
        face.src = dataURL;
    }
    reader.readAsDataURL(file);
}

$(window).load(function(){
	$("#wrapper").animate({
		opacity: 1
	});
});

function buildImages() {
	ctx.fillStyle = "#FFFFFF";
	ctx.fillRect(0,0,canvas.width,canvas.height);

	var x = $("#dealwithit .overlay .person").position().left;
	var y = $("#dealwithit .overlay .person").position().top;
	var w = $("#dealwithit .overlay .person").width();
	var h = $("#dealwithit .overlay .person").height();
	ctx.drawImage( face, x, y, w, h );

	var dataURL = canvas.toDataURL("image/png");
	var el = $('<img/>', { src : dataURL }).addClass('ci');
	$('#wrapper').append(el);

	$(".canvas-wrapper .overlay").css({
		opacity: 0
	});

	$("#loading").show();
	var image = canvas.toDataURL("image/png");
	$(".canvas-wrapper").append(image);

	uploadimage(image);
}

var canvas, ctx;
var face = new Image();
$(document).ready(function() {
	canvas = $("#dealwithit canvas")[0];
	canvas.width = 580;
	canvas.height = 580;
	ctx = canvas.getContext("2d");

	$(".fileselect").on('change',function(event) {
		handleFile( this.files[0] );
		return false;
	});

	$("#makegif").click(function(event) {
		if( !$(this).hasClass("inactive") ) {
			$(this).addClass("inactive")

			$("#loading").show();
			
			buildImages();
		}

		return false;
	});
});