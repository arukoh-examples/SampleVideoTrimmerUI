package tk.arukoh.videotrimmerui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import mx.controls.HSlider;
	import mx.core.IMXMLObject;
	import mx.events.FlexEvent;
	import mx.events.SliderEvent;
	import org.osmf.events.TimeEvent;
	import spark.components.Button;
	import spark.components.Label;
	import spark.components.NumericStepper;
	import spark.components.TextInput;
	import spark.components.VideoDisplay;
	import tk.arukoh.utils.HumanReadablizer;
	
	public class MainHelper implements IMXMLObject
	{
		private const SILDER_LABELS_DIV:Number = 10;
		
		[Bindable]
		internal var sourceTimeLabelText:String = sourceTimeFormat(0, 0);
		[Bindable]
		internal var durationLabelText:String = durationFormat(0);
		[Bindable]
		internal var fileSizeLabelText:String = fileSizeFormat(0);
		
		private var main:Main;
		
		public function MainHelper()
		{
		}
		
		public function initialized(document:Object, id:String):void
		{
			main = Main(document);
			main.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			main.loadButton.addEventListener(MouseEvent.CLICK, loadButton_clickHandler);
			videoDisplay.addEventListener(TimeEvent.DURATION_CHANGE, videoDisplay_durationChangeHandler);
			videoSlider.addEventListener(SliderEvent.THUMB_PRESS, videoSlider_thumbPressHandler);
			videoSlider.addEventListener(SliderEvent.THUMB_RELEASE, videoSlider_thumbReleaseHandler);
			videoSlider.addEventListener(SliderEvent.THUMB_DRAG, videoSlider_changeHandler);
			videoSlider.addEventListener(SliderEvent.CHANGE, videoSlider_changeHandler);
			videoSliderEx.addEventListener(SliderEvent.THUMB_DRAG, videoSliderEx_changeHandler);
			videoSliderEx.addEventListener(SliderEvent.CHANGE, videoSliderEx_changeHandler);
			startNumericStepper.addEventListener(Event.CHANGE, startNumericStepper_changeHandler);
			endNumericStepper.addEventListener(Event.CHANGE, endNumericStepper_changeHandler);
		}
		
		private function loadButton_clickHandler(event:MouseEvent):void
		{
			updateVideoState(0, 0, [NaN,NaN,NaN]);
			videoDisplay.source = startVideoDisplay.source = endVideoDisplay.source = sourceURL.text;
		}
		
		private function videoDisplay_durationChangeHandler(event:TimeEvent):void
		{
			var duration:Number = isNaN(videoDisplay.duration) ? 0 : videoDisplay.duration;
			if (duration > 0)
			{
				sourceTimeLabelText = sourceTimeFormat(0, duration);
				videoSlider.maximum = videoSliderEx.maximum = duration;
				var labels:Array = [];
				for (var i:int = 0; i < SILDER_LABELS_DIV + 1; i++) labels.push(int(duration * i / SILDER_LABELS_DIV));
				videoSlider.labels = labels;
				videoSlider.tickInterval = int(duration / SILDER_LABELS_DIV);
				startNumericStepper.minimum = 0;
				endNumericStepper.maximum = int(duration);
				updateVideoState(0, duration, [0,0,duration]);
			}
		}
		
		private function videoSlider_thumbPressHandler(event:SliderEvent):void
		{
		}
		
		private function videoSlider_thumbReleaseHandler(event:SliderEvent):void
		{
		}
		
		private function videoSlider_changeHandler(event:SliderEvent):void
		{
			var value:Number = event.value;
			var slider:HSlider = HSlider(event.currentTarget);
			switch (event.thumbIndex)
			{
				case 0: 
					updateVideoState(value, slider.values[1], [value,value,NaN]);
					break;
				case 1: 
					updateVideoState(slider.values[0], value, [value,NaN,value]);
					break;
			}
		}
		
		private function videoSliderEx_changeHandler(event:Event):void
		{
			if (event.type == SliderEvent.CHANGE)
			{
				var slider:spark.components.HSlider = spark.components.HSlider(event.currentTarget);
				updateVideoState(videoSlider.values[0], videoSlider.values[1],
					[slider.value,videoSlider.values[0], videoSlider.values[1]]);
			}
		}
		
		private function startNumericStepper_changeHandler(event:Event):void
		{
			var stepper:NumericStepper = NumericStepper(event.currentTarget);
			updateVideoState(stepper.value, videoSlider.values[1], [stepper.value,stepper.value,NaN]);
		}
		
		private function endNumericStepper_changeHandler(event:Event):void
		{
			var stepper:NumericStepper = NumericStepper(event.currentTarget);
			updateVideoState(videoSlider.values[0], stepper.value, [stepper.value,NaN,stepper.value]);
		}
		
		private function updateVideoState(start:Number, end:Number, seeks:Array):void
		{
			var duration:Number = end - start;
			durationLabelText = durationFormat(duration);
			fileSizeLabelText = fileSizeFormat(videoFileSize(duration));
			videoSlider.values = [start, end];
			startNumericStepper.maximum = int(end) - 1;
			startNumericStepper.value = int(start);
			endNumericStepper.minimum = int(start) + 1;
			endNumericStepper.value = int(end);
			if (!isNaN(seeks[0]))
			{
//				videoSliderEx.value = seeks[0];
				videoDisplay.seek(seeks[0]);
			}
			if (!isNaN(seeks[1])) startVideoDisplay.seek(seeks[1]);
			if (!isNaN(seeks[2])) endVideoDisplay.seek(seeks[2]);
		}
		
		private function videoFileSize(duration:Number):Number
		{
			if (isNaN(videoDisplay.duration) || videoDisplay.duration == 0) return 0;
			return videoDisplay.bytesTotal * duration / videoDisplay.duration;
		}
		
		private function sourceTimeFormat(s:Number, e:Number):String
		{
			return HumanReadablizer.time(s) + "/" + HumanReadablizer.time(e);
		}
		
		private function durationFormat(value:Number):String
		{
			return "Duration: " + HumanReadablizer.time(value);
		}
		
		private function fileSizeFormat(value:Number):String
		{
			return "File Size: " + HumanReadablizer.bytes(value);
		}
		
		private function get videoDisplay():VideoDisplay
		{
			return main.videoDisplay;
		}
		
		private function get startVideoDisplay():VideoDisplay
		{
			return main.startVideoDisplay;
		}
		
		private function get endVideoDisplay():VideoDisplay
		{
			return main.endVideoDisplay;
		}
		
		private function get videoSlider():HSlider
		{
			return main.videoSlider;
		}
		
		private function get videoSliderEx():spark.components.HSlider
		{
			return main.videoSliderEx;
		}
		
		private function get startNumericStepper():NumericStepper
		{
			return main.startNumericStepper;
		}
		
		private function get endNumericStepper():NumericStepper
		{
			return main.endNumericStepper;
		}
		
		private function get sourceURL():TextInput
		{
			return main.sourceURL;
		}
	
	}

}