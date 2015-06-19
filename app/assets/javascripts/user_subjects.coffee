# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
	$('#js_ku_users_datatable').dataTable
		sPaginationType: "full_numbers";

	$(document).ready ->
		$('#js_ku_users_datatable').dataTable().rowReordering()