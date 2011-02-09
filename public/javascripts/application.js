// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	// PLACEHOLDER
	$('input[placeholder],textarea[placeholder]').placeholder();

	// AUTOGROW FOR COMMENT
	$("#comment_content").autoGrow();

	// AJAXY STUFF FOR COMMENT SUBMITTING
  $("#new_comment")
		.bind("ajax:loading", function(){
		  $(this).find('.ajax-loader').toggle();
		  $(this).find(":input").attr('disabled', 'disabled');
		})
		.bind("ajax:success", function(obj, data, xhr) {
		  $(this).find(".error_messages").hide();
		  $(this).find(":input").not(":submit").val('');
		})
		.bind("ajax:failure", function(data, xhr, err) {
		  if (xhr.status == 403)
		    $(this).find(".error_messages").html($(xhr.responseText)).show();
		})
		.bind("ajax:complete", function(){          
		  $(this).find(":input").removeAttr('disabled');
		  $(this).find('.ajax-loader').toggle();
		});
  $(".bubble blockquote").live('mouseover mouseout', function(event){
		if (event.type == "mouseover")
			$(this).find('p.comment-no-vote').show();
		else if (event.type == "mouseout")
			$(this).find('p.comment-no-vote').hide();
	});
	
	// AUTOCOMPLETE
	$("#q_search").autocomplete({
	  serviceUrl:showsPath,
	  minChars:2,
		selectFirst:true,
	  onSelect: function(value, data){
	    window.location = '/shows/' + data.param;          
	  } 
	});
	
	// MENU STUFF
	var menuLoginPosition = $("#menu-login").offset();
	$("#menu-login").find("ul.submenu").css({left: menuLoginPosition.left+3+"px", top: menuLoginPosition.top+35+"px"});
	$("#menu-login .folded").hover(function(){
		$(this).children("ul.submenu").show();
	},
	function(){
		$(this).children("ul.submenu").hide()
	});
	
	// NOTICES Stuff
	$(".flash-handler").each(function(){
		$(this).click(function(){
			$(this).parent().parent().fadeOut();
			return false;
		});
	});
	setTimeout("clearFlashes()", 3000); // Auto hide flashes after 3 secs
	
	// THUMBSUPS
	$("a.thumbs-up,a.thumbs-down").livequery(function(){
		$(this).tipsy();
	});
	$("a.thumbs-up,a.thumbs-down").livequery('click', function(){
		$(this).tipsy('hide');
	});
});

function clearFlashes(){
	$("#flash_notice").fadeOut();
}

function showMoreDescription(linkMore)
{
	linkMore = $(linkMore);
	linkMore.next().toggle();
	linkMore.hide();
}

function updateProcessingElements(intervalId, eltPath, updateLink){
  intervalId = window.setInterval(function(){
    $(eltPath).each(function(){
      var elt = $(this);
      $.ajax({
        url: updateLink,
        success: function(data){
          elt.replaceWith(data);
          elt.removeClass("processing");
          window.clearInterval(intervalId);
        }
      });
    })
  }, 2000);
}