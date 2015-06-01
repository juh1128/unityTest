using UnityEngine;
using System.Collections;

public class ContentPanelController : MonoBehaviour {

    public GameObject[] panels; //컨텐츠 패널들
    public GameObject footerPanel;

    int nowDisplayIndex = 0;
    int panelNum = 4; //컨텐츠 패널 개수
    bool isSliding = false;
    bool initPosition = false;
    AnySwipe swipe;

    RectTransform nextPanelRect;
    RectTransform destPanelRect;

	// Use this for initialization
	void Start () {
        swipe = GetComponent<AnySwipe>();
        panelNum = panels.Length;
	}
	
	void Update () {
        if (swipe.IsSwiped())
        {
            if (swipe.CheckForSwipe(Vector2.right))
            {
                slidePrev();
                footerPanel.SendMessage("highlightMenu", nowDisplayIndex);
            }
            else if (swipe.CheckForSwipe(-Vector2.right))
            {
                slideNext();
                footerPanel.SendMessage("highlightMenu", nowDisplayIndex);
            }
        }
	}

    public void slideIndex(int index)
    {
        if (!isSliding)
        {
            if (index != nowDisplayIndex && 0 <= index && index < panelNum)
            {
                //방향 체크
                int dir = (nowDisplayIndex < index) ? 1 : -1;
                //패널 위치 교체
                int nextIndex = nowDisplayIndex + dir;
                nextPanelRect = panels[nextIndex].GetComponent<RectTransform>();
                destPanelRect = panels[index].GetComponent<RectTransform>();
                swapPosition(nextPanelRect, destPanelRect);

                //패널 슬라이드
                if (dir > 0)
                {
                    slideNext();
                }
                else
                {
                    slidePrev();
                }

                //위치 초기화 및 후처리
                nowDisplayIndex = index;
                footerPanel.SendMessage("highlightMenu", nowDisplayIndex);
                initPosition = true;
            }
        }
    }

    void slideReady()
    {
        isSliding = false;
        if (initPosition)
        {
            swapPosition(nextPanelRect, destPanelRect);
            gameObject.GetComponent<RectTransform>().localPosition = new Vector3(nowDisplayIndex * -360, 20,0);
            initPosition = false;
        }
    }

    void slideNext()
    {
        if (!isSliding)
        {
            if (nowDisplayIndex < panelNum-1)
            {
                Vector3 nowPos = gameObject.GetComponent<RectTransform>().position;
                Vector3 nextPos = new Vector3(nowPos.x - Screen.width, nowPos.y, 0);

                iTween.MoveTo(gameObject,
                    iTween.Hash("onComplete", "slideReady", "easetype", "easeOutCubic",
                    "position", nextPos, "time", 0.5f));

                isSliding = true;
                nowDisplayIndex++;
            }
        }
    }

    void slidePrev()
    {
        if (!isSliding)
        {
            if (nowDisplayIndex > 0)
            {
                Vector3 nowPos = gameObject.GetComponent<RectTransform>().position;
                Vector3 prevPos = new Vector3(nowPos.x + Screen.width, nowPos.y, 0);

                iTween.MoveTo(gameObject, iTween.Hash("onComplete", "slideReady", "easetype", "easeOutCubic",
                    "position", prevPos, "time", 0.5f));

                isSliding = true;
                nowDisplayIndex--;
            }
        }
    }

    void swapPosition(RectTransform a, RectTransform b)
    {
        Vector2 tempPos = a.position;
        a.position = b.position;
        b.position = tempPos;  
    }
}
