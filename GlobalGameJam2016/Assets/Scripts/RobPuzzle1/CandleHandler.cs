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
		candles = GetComponentsInChildren<Transform>().Where(x => x.GetComponent<Renderer>() != null && x.GetComponent<ParticleSystem>() == null)
													  .Select(x => x.gameObject).ToList();
		circleCandles = new List<GameObject>();

		var cachedRotation = candleCircleCenter.transform.localRotation;

		for (int i = 0; i < candleCount; i++){
			var candle = GameObject.Instantiate(candlePrefab);
			candle.transform.parent = transform;

			candle.transform.localRotation = Quaternion.identity;
			candle.transform.position = candleCircleCenter.transform.position + candleCircleCenter.transform.right * candleSpread;
			candleCircleCenter.transform.Rotate(Vector3.forward, 360f / candleCount);

			circleCandles.Add(candle);
		}

		candleCircleCenter.transform.localRotation = cachedRotation;
	}

	public void LightCandles(){
		this.StartSafeCoroutine(LightAllCandles());
	}

	IEnumerator LightAllCandles(){
		yield return new WaitForSeconds(1);

		this.StartSafeCoroutine(LightAllCandlesInList(candles, .2f));
		yield return new WaitForSeconds(.35f);
		this.StartSafeCoroutine(LightAllCandlesInList(circleCandles, .1f));
	}

	IEnumerator LightAllCandlesInList(List<GameObject> candleList, float delay){
		var candlePositions = candleList.Select(x => x.transform.localPosition.x).Distinct().ToList();
		candlePositions.Sort();
		candlePositions.Reverse();

		for (int i = 0; i < candlePositions.Count; i++){
			var listOfCandles = candleList.Where(x => x.transform.localPosition.x == candlePositions[i])
					  					  .ToList();
			listOfCandles.ForEach(x => x.GetComponentInChildren<ParticleSystem>().Play());
			yield return new WaitForSeconds(delay);
		}

	}
}
