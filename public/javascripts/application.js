// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	$('input[placeholder],textarea[placeholder]').placeholder();
	$("#comment_content").autoGrow();
  $("#new_comment")
      .bind("ajax:loading",  function(){
        $(this).find('.ajax-loader').toggle();
        $(this).find(":input").attr('disabled', 'disabled');
      })
      .bind("ajax:success", function(obj, data, xhr) {
        $(this).find(".error_messages").hide();
        $(data).insertAfter($("#comments").children("div.new-bubble"));
        $(this).find(":input").not(":submit").val('');
      })
      .bind("ajax:failure", function(data, xhr, err) {
        console.info(xhr.responseText);
        if (xhr.status == 403)
          $(this).find(".error_messages").html($(xhr.responseText)).show();
      })
      .bind("ajax:complete", function(){          
        $(this).find(":input").removeAttr('disabled');
        $(this).find('.ajax-loader').toggle();
      });
});

function showMoreDescription(linkMore)
{
	linkMore = $(linkMore);
	linkMore.next().toggle();
	linkMore.hide();
	console.info(linkMore.next());
}