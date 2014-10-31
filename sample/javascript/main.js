$(function(){
 $.get("./perl/getCount.cgi",function(data){
  $("#counter").text(
   "TOTAL: "+data.total +"\n"+
   "TODAY: "+data.day[0] + "\n"+
   "YESTERDAY: "+data.day[1] + "\n"
  );

  // 日付
  var updateDay= new Date(data.updateTime* 1000);
  $("#updateDay").text(
   "カウンター更新日:"+(updateDay.getMonth()+1)+"月"+updateDay.getDate()+"日"
  );
 });
 var scrollTime=60;
 autoScrollTop={
  id:null,
  time:null,
  reset:function(time){
   var y = (window.pageYOffset !== undefined) ? window.pageYOffset : (document.documentElement || document.body.parentNode || document.body).scrollTop;
   if(y>0){
    autoScrollTop.time=time;
    clearTimeout(autoScrollTop.id);
    autoScrollTop.id=setTimeout(autoScrollTop.loop,1000);
   }
  },
  loop:function(){
   autoScrollTop.time--;
   if(autoScrollTop.time<=0){
    $(document).scrollTop(0);
   }else{
    autoScrollTop.id=setTimeout(autoScrollTop.loop,1000);
   }
  }
 };
 $(document).on("scroll",function(e){
  autoScrollTop.reset(scrollTime);
 });
 autoScrollTop.reset(scrollTime);
});
