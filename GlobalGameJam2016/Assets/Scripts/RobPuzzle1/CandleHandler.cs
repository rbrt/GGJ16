using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class CandleHandler : MonoBehaviour {

	[SerializeField] protected GameObject candlePrefab;
	[SerializeField] protected GameObject candleCircleCenter;

	List<GameObject> candles;
	List<GameObject> circleCandles;

	int candleCount = 20;
	float candleSpread = 22;

	void Awake(){
		candles = GetComponentsInChildren<Transform>().Where(x => x.GetComponent<Renderer>() != null).Select(x => x.gameObject).ToList();
		circleCandles = new List<GameObject>();

		var cachedRotation = candleCircleCenter.transform.localRotation;

		for (int i = 0; i < candleCount; i++){
			var candle = GameObject.Instantiate(candlePrefab);
			candle.transform.parent = transform;

			candle.transform.localRotation = Quaternion.identity;
			candle.transform.position = candleCircleCenter.transform.position + candleCircleCenter.transform.right * candleSpread;
			candleCircleCenter.transform.Rotate(Vector3.forward, 360f / candleCount);
		}

		candleCircleCenter.transform.localRotation = cachedRotation;
	}
}
