var Dashboard = (function () {

	var showForm = function(id){
		var el = $("#index_"+id)
		el.show()
		el.siblings("div").addClass('hide');
    $(".edit_"+id).addClass('hide');
    $("#private_"+id).addClass('hide');
	};

	var hideForm = function(id){
		var el = $("#index_"+id)
		el.hide()
		el.siblings("div").removeClass('hide');
    $(".edit_"+id).removeClass('hide');
    $("#private_"+id).removeClass('hide');
	};

	var showFileField = function(obj){
		var role = $(obj).val();
		var logo = $("#logo");

		if(role == "publisher" || role == "translator")
		  logo.removeClass('hide');
		else
		  logo.hasClass('hide') ? false : logo.addClass('hide')
	};
	
	return {
		showForm:showForm,
		hideForm:hideForm,
		showFileField:showFileField
	};	
})();