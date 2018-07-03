$('#newIllustrationForm').html("<%= escape_javascript(render(:partial=>"illustration_form"))%>");

$(document).ready(function() {
	$('#uploadModal').modal({
		show: true,
		keyboard: true
	}).on('shown.bs.modal', function () {
   			$("#confirm_form").modal('show');
		});
});
