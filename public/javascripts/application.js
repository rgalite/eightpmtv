// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(document).ready(function(){
	$('input[placeholder],textarea[placeholder]').placeholder();
})

function showMoreDescription(linkMore)
{
	linkMore = $(linkMore);
	linkMore.next().toggle();
	linkMore.hide();
	console.info(linkMore.next());
}