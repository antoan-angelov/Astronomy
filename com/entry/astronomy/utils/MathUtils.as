package com.entry.astronomy.utils {
	import flash.geom.Vector3D;
	
	/**
	 * Klas s polezni matematicheski funkcii
	 * @author Antoan Angelov
	 */
	public class MathUtils {
		
		/**
		 * Prevryshta ygyl ot intervala [-beskrainost;+bezkrainost] v ygyl ot intervala [-180; 180]
		 * @param angle Ygyla
		 * @param add Dali da dobavi chislo kym nego predvaritelno
		 * @return Ygyla v intervala [-180; 180]
		 */
		public static function normalize(angle:Number, add:Number = 0):Number {
			
			angle += add;
			
			while(angle > 180)
				angle -= 360;
			
			while(angle < -180)
				angle += 360;
			
			return angle;			
		}
		
		/**
		 * Vryshta ygyl mejdu dadeni 2 tochki i koordinata (0,0,0)
		 * @param x1
		 * @param y1
		 * @param x2
		 * @param y2
		 * @return Ygyl mejdu dvete tochki i koordinata (0,0,0)
		 */
		public static function getAngle(x1:Number, y1:Number, x2:Number = 0, y2:Number = 0):Number {
			var dx:Number = x2 - x1, dy:Number = y1 - y2;
			return Math.atan2(dy, dx);
		}
		
		/**
		 * Vryshta proizvolno chislo v zadadeniq zatvoren interval
		 * @param num1 Dolnata granica na intervala
		 * @param num2 Gornata granica na intervala ili 0
		 * @return Proizvolno chislo v zadadeniq interval
		 */
		public static function getRandom(num1:int, num2:int = 0):int {
			
			var rand:Number = Math.random();
			var randInt:int = Math.floor(rand*(num2-num1+1)+num1);
			
			return randInt;
		}		
		
		/**
		 * Premahva opredelen element ot masiv
		 * @param array Masivyt, ot koito da premahne elementa
		 * @param i Indeksyt na elementa, koito da byde premahnat ot array
		 */
		public static function removeElement(array:Array, i:int):void {
			var n:int = array.length-1;
			
			for(; i<n; i++)
				array[i] = array[i+1];
			
			array.pop();
		}
	}
}
