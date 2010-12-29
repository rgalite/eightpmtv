// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	$('input[placeholder],textarea[placeholder]').placeholder();
	$("#comment_content").autoGrow();
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
});

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