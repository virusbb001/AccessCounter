$(function(){
 $.get("./perl/getCount.cgi",function(data){
  $("#counter").text(
   "TOTAL: "+data.total +"\n"+
   "TODAY: "+data.day[0] + "\n"+
   "YESTERDAY: "+data.day[1] + "\n"
  );
 });
});
