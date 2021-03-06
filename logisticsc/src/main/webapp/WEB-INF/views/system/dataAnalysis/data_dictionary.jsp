<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>数据字典</title>
<link href="${configProps['resources']}/newbui/css/bs3/dpl-min.css" rel="stylesheet">
<link href="${configProps['resources']}/newbui/css/bs3/bui-min.css" rel="stylesheet">
 <style>
    /**内容超出 出现滚动条 **/
    .bui-stdmod-body feedback_dia{
      overflow-x : hidden;
      overflow-y : auto;
    }
  </style>
</head>
<body>
	<div class="panel">
        <div class="panel-header">
           	<h2>数据字典</h2>
        </div>
        <div class="panel-body">
	        <form id="search_form" class="well form-inline">
	        	起始时间：<input id="start_time" name="startTime" type="text" class="calendar"/>-<input id="end_time" name="endTime" type="text" class="calendar"/>
        		<input id="condition" name="condition" type="text" placeholder="主题">
	        	<button type="button" class="button button-normal" onclick="search()">查询</button>
	        </form>
	     	<div id="render_grid">
	  
	       	</div>
	       	<div id="pagingbar">
	       	
	       	</div>
       	</div>
    </div>
    <!-- 默认隐藏 -->
    <div id="add_edit_dia" class="hide">
    	<form class="form-horizontal">
    		<div class="control-group">
    			<div class="control-label">主题：</div>
    			<div class="controls">
    				<input name="title" type="text"/>
    			</div>
    		</div>
    		<div class="control-group">
    			<div class="control-label">信息类型：</div>
    			<div class="controls">
    				<select id="type" name="type" class="input-small">
    				</select>
    			</div>
    		</div>
    		<div class="control-group">
    			<div class="control-label">内容：</div>
    			<div class="controls control-row-auto">
    				<textarea name="content" class="control-row2 input-large"></textarea>
    			</div>
    		</div>
    	</form>
    </div>
	<script type="text/javascript" src="${configProps['resources']}/js/jquery-1.11.1.min.js"></script>
	<script type="text/javascript" src="${configProps['resources']}/newbui/js/bui.js"></script>
	<script type="text/javascript">
		//查询
		function search(){
			var params={
				startTime:$("#start_time").val(),
				endTime:$("#end_time").val(),
				condition:$("#condition").val()
			}
			store.load(params);
		}
		
		//表格渲染
		BUI.use(['bui/grid','bui/data','bui/toolbar','bui/format','bui/select'],
					function(Grid,Data,Toolbar,Format,Select){
			var Grid = Grid,
			Store = Data.Store,
			columns = [
				{title : '主题', dataIndex : 'title'},
				{title : '内容', dataIndex : 'content'},
				{title : '信息类型',dataIndex :'typeVal'},
				{title : '时间', dataIndex : 'createTime',renderer:BUI.Grid.Format.datetimeRenderer},
			];
			editing = new Grid.Plugins.DialogEditing({
		          contentId : 'add_edit_dia', //设置隐藏的Dialog内容
		          editor:{
		        	  title:'信息发布',
		        	  width:600,
		        	  success:function(){
		        		  var editor = this;
		        		  	form = editor.get("form");
		        		  form.ajaxSubmit({
		        			  	url:'<%=request.getContextPath()%>/tms/sys/publish/insert.shtml',
		        			  	type:'post',
		        			  	dataType:'json',
		        				success:function(data){
		        					if(data.result == true){
		        						alert("发布成功");
		        						editor.close();
		        						store.load();
		        					}
					        	},
					        	error:function(){
					        		  alert("系统错误");
					        		  editor.close();
					        	}
		          			});
		        	  }
		          }
		    });
			store = new Store({
				url: '<%=request.getContextPath()%>/tms/sys/publish/search.shtml',
				autoLoad:true,
				pageSize:10,
			});

			grid = new Grid.Grid({
			   	render:'#render_grid',
			  	autoRender:true, 
				columns : columns,
				forceFit : true,
				store : store,
				loadMask: true,//加载数据时显示屏蔽层
				plugins : [Grid.Plugins.CheckSelection,editing],
				tbar:{
					items : [{
	                  	btnCls : 'button button-small',
	                  	text : '<i class="icon-plus"></i>发布',
	                  	listeners : {
	                    	"click":publish
	                  	}
	                },{
	                  	btnCls : 'button button-small',
	                  	text : '<i class="icon-plus"></i>删除',
	                  	listeners : {
	                    	'click':deletePub
	                  	}
	                }]
				}
				
			});
			function publish(){
				renderPubType();
				editing.add();
			}
			function deletePub(){
				var selects = grid.getSelection();
				var length = selects.length;
				if(length>0){
					var array = [];
					for(var i=0;i<length;i++){
						array.push(selects[i].id);
					}
					$.ajax({
						url:'<%=request.getContextPath()%>/tms/sys/publish/delete.shtml',
						type:'post',
						data:{publishIds:array},
						dataType:'json',
						success:function(data){
							if(data.result == true){
								alert("操作成功");
								store.load();
							}
						}
					})
				}
			}
			//分页工具条
			var bar = new Toolbar.NumberPagingBar({
		          render : '#pagingbar',
		          autoRender: true,
		          elCls : 'pagination pull-right',
		          store : store
		    });
		});	
		
		//日期加载
		BUI.use('bui/calendar',function(Calendar){
	        var datepicker = new Calendar.DatePicker({
	        	trigger:'.calendar',
	        	autoRender : true
	    	});
	    });
		function renderPubType(){
			$.ajax({
				url:'<%=request.getContextPath()%>/dic/publishtype.shtml',
				type:'post',
				dataType:'json',
				success:function(data){
					if(data.result == true){
						var rows = data.rows,
						type = $("#type");
						type.empty();
						type.append("<option value=''>请选择</option>");
						for(var i=0;i<rows.length;i++){
							type.append("<option value='"+rows[i].id+"'>"+rows[i].name+"</option>");
						}
					}
				}
			})
		}
	</script>
</body>
</html>