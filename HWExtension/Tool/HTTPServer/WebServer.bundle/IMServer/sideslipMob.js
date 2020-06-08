(function () {
	//页面是否发生滚动, 页面滚动禁止侧滑操作
	var isScroll = false;
	//是否开开启侧滑操作
	var isMove = true;
	//是否处于测滑动中状态
	var isMove_process = false;
	
	//滚动条是否在顶部
	var isScroll_top = true;
	//滚动条是否在底部
	var isScrill_bottom = false;
	
	var sideslip = {
		touch:function(event) {
			//侧滑组件dom
			var sideslipBody = null;
			//侧滑菜单
			var sideslipTitle = null;
			
			//获取触发滑动事件的Dom元素(由于dom 属性nodeName 节点存在的表现形式不同)
			var childNodes = event.currentTarget.childNodes;
			for(var i = 0;i<childNodes.length;i++) {
				var nodes = childNodes[i];
				if('DIV' == nodes.nodeName) {
					if(nodes.getAttribute('class').match('sideslipBody')) {
						sideslipBody = nodes;
					}else if(nodes.getAttribute('class').match('sideslipTitle')) {
						sideslipTitle = nodes;
					}
				}
			}
			//实际侧滑菜单按钮
			var menu = sideslipTitle.children;
			switch(event.type){
				case "touchstart" :
					time = setTimeout(function() {
						sideslipBody.style.backgroundColor = 'rgba(230,230,230,1)';
					},200);
					sideslip.closeMenu(event);
					sideslipBody.style.transitionDuration = "0.2s";
					marginRight = window.getComputedStyle(sideslipBody,"").transform;
					marginRight = Math.abs(Number(marginRight.substring(7,marginRight.length-1).split(",")[4]));
					//触摸点x轴距离
					$startX = event.touches[0].clientX;
					//触摸点Y轴距离
					$startY = event.touches[0].clientY;
					//触摸点至移动之后得到的x轴距离
					touchesX = 0;
					//触摸点至移动之后得到的Y轴距离
					touchesY = 0;
					break;
				case "touchmove" :
					sideslip.closeMenu(event);
					sideslipBody.style.backgroundColor = 'white';
					//计算侧滑菜单宽度
					subWidth = 0;
					for(var i = 0;i<menu.length;i++) {
						subWidth = subWidth + menu[i].clientWidth;
					}
		
					sideslipBody.style.transitionDuration = "0s";
					$moveX = event.touches[0].clientX;
					$moveY = event.touches[0].clientY;
					touchesX = $startX - $moveX;
					touchesY = $startY - $moveY;
		//			console.log("移动X距离:"+touchesX);
		//			console.log("移动Y距离:"+touchesY);
					if(!isMove || isScroll) {
						return false;
					}
					//继续执行
					if(isMove_process) {
						event.preventDefault();
					}else if(touchesX < (Math.abs(touchesY))) {
						return false;
					}
					
					isMove_process = true;
					//触发显示侧滑元素，解决IOS端快速滑动闪屏的问题
					if('none' == window.getComputedStyle(sideslipTitle).display) {
						sideslipTitle.style.display = 'block';
					}
					// 滑块侧滑操作开始处理逻辑
					if(marginRight >= 0) {
						if(marginRight+touchesX < 0 ) {
							sideslipBody.style.transform = 'translate3d(0px,0px, 0px)';
						}else if(marginRight+touchesX <= 500) {
		//					isMove = true;
							sideslipBody.style.transform = 'translate3d(-'+(marginRight+touchesX)+'px,0px, 0px)';
						}else {
							sideslipBody.style.transform = 'translate3d(-'+subWidth+'px,0px, 0px)';
						}
					}else{
							sideslipBody.style.transform = 'translate3d(0px,0px, 0px)';
					}
					break;
				case "touchend" :
					clearTimeout(time);
					sideslipBody.style.backgroundColor = 'white';
					sideslipBody.style.transitionDuration = "0.2s";
					marginRight = window.getComputedStyle(sideslipBody,"").transform;
					marginRight = Math.abs(Number(marginRight.substring(7,marginRight.length-1).split(",")[4]));
					if(marginRight <= 58 || touchesX <= -58) {
						//触发显示侧滑元素，解决IOS端快速滑动闪屏的问题
						if('none' != window.getComputedStyle(sideslipTitle).display) {
							setTimeout(function() {
								sideslipTitle.style.display = 'none';
							},220);
						}
						sideslipBody.style.transform = 'translate3d(0px,0px, 0px)';
					}else {
						sideslipBody.style.transform = 'translate3d(-'+subWidth+'px,0px, 0px)';
					}
					isMove_process = false;
					isScroll = false;
					break;
				case "ontouchcancel" :
					isMove_process = false;
					isScroll = false;
					break;
			}
		},
		//触摸关闭侧滑菜单
		closeMenu:function(event) {
			var sideslipBody = document.getElementsByClassName("sideslipBody");
			var index = 0;
			for(var i = 0;i<sideslipBody.length;i++) {
				var thises = window.getComputedStyle(sideslipBody[i]).transform;
				thises = Math.abs(Number(thises.substring(7,thises.length-1).split(",")[4]));
				if(thises > 0) {
		//			console.log(event.currentTarget.querySelector('.sideslipBody'));
		//			console.log(sideslipBody[i]);
					if(event.currentTarget.querySelector('.sideslipBody') != sideslipBody[i]) {
		////				event.preventDefault();
						sideslipBody[i].style.transform = 'translate3d(0px,0px, 0px)';
						index = i;
		//				console.log(sideslipBody[i]);
						setTimeout(function() {
							if("DIV" == sideslipBody[index].nextSibling.nodeName) {
								sideslipBody[index].nextSibling.style.display = 'none';
							}else {
								sideslipBody[index].nextSibling.nextSibling.style.display = 'none';
							}
						},220);
					}
				}
			}
		},
		restoreEvent:function(event) {
			switch(event.type){
				case "touchstart" :
					$startY = event.touches[0].clientY;
					break;
				case "touchmove" :
					$moveY = event.touches[0].clientY;
					//滑动距离
					touchesY = $startY - $moveY;
					//滚动条顶部
					if(isScroll_top) {
						if(touchesY < 0) {
							event.preventDefault();
						}else{
							var scrollWrap = document.getElementById("scrollWrap");
							if(scrollWrap.scrollHeight == scrollWrap.clientHeight) {
								event.preventDefault();
							}else {
								event.stopPropagation();
							}
						}
					//滚动条底部
					}else if(isScrill_bottom){
						if(touchesY	> 0) {
							event.preventDefault();
						}else{
							event.stopPropagation();
						}
					}
					break;
				case "touchend" :
					break;
			}
		},
		scrollEvent:function(event) {
			var tabView = document.getElementById("scrollWrap");
		    var contentHeight = tabView.scrollHeight, //内容高度
		    scrollTop = tabView.scrollTop; //滚动高度
		    viewHeight = tabView.clientHeight;
		
			if(scrollTop == 0) {
				isScroll_top = true;
			}else{
				isScroll_top = false;
			}
		    if ((scrollTop / (contentHeight - viewHeight)) == 1 ) {
		        isScrill_bottom = true;
		    }else {
		    	isScrill_bottom = false;
		    }
		    //页面滚动
		    if(!isMove_process) {
		    	isScroll = true;
		    }
		    
		    setTimeout(function() {
		    	isScroll = false;
		    },500);
		},
		sideslipInsert:function(event) {
			var list = event.target.classList.contains('list');
			if(list) {
				event.target.addEventListener("touchstart",sideslip.touch,false);
				event.target.addEventListener("touchmove",sideslip.touch,false);
				event.target.addEventListener("touchend",sideslip.touch,false);
				sideslip.scrollEvent();
			}
		},
		resize:function() {
			sideslip.scrollEvent();
		}
	}
	
	document.addEventListener("DOMContentLoaded",function() {
		/**
		 * 移动端侧滑菜单开始逻辑控制
		 */
		var list = document.getElementsByClassName("list");
		for(var i = 0;i<list.length;i++) {
			list[i].addEventListener("touchstart",sideslip.touch,false);
			list[i].addEventListener("touchmove",sideslip.touch,false);
			list[i].addEventListener("touchend",sideslip.touch,false);
		}
		
		/**
		 * 添加侧滑菜单触发
		 */
		document.getElementById("scrollWrap").addEventListener('DOMNodeInserted',sideslip.sideslipInsert);
		
		/**
		 * iOS端禁止列表顶部下拉和底部上拉露出浏览器灰色背景
		 */
		document.getElementById("scrollWrap").addEventListener("touchstart",sideslip.restoreEvent);
		document.getElementById("scrollWrap").addEventListener("touchmove",sideslip.restoreEvent);
		document.getElementById("scrollWrap").addEventListener("touchend",sideslip.restoreEvent);
		document.getElementById("scrollWrap").addEventListener("scroll",sideslip.scrollEvent);
		
		/**
		 * 窗口变化处理
		 */
		window.addEventListener("resize",sideslip.resize);
	});
})();