using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
[RequireComponent(typeof(RectTransform))]
[DisallowMultipleComponent]
public class Lua_ScrollView : ScrollRect
{
    public enum eLayoutType
    {
        Horizontal = 0,
        Vertical = 1,
    }
    #region ˽���ֶ�
    /// <summary>
    /// �������� 
    /// </summary>
    [SerializeField]
    private eLayoutType m_LayoutType = eLayoutType.Vertical;
    [SerializeField]
    private Vector2 m_Spacing = Vector2.zero;
    #endregion
    /// <summary>
    /// �������� 0||1
    /// </summary>
    public int layoutType
    {
        get
        {
            return (int)m_LayoutType;
        }
        set
        {
            m_LayoutType = (eLayoutType)value;
        }
    }
    /// <summary>
    /// ����Ԥ����
    /// </summary>
    [SerializeField]
    public GameObject itemPrefab;
    /// <summary>
    /// ÿ�������ʾ����
    /// </summary>
    [SerializeField]
    public uint perLineItemNum = 99999;



    public float spacingX
    {
        get
        {
            return m_Spacing.x;
        }
        set
        {
            m_Spacing = new Vector2(value, m_Spacing.y);
        }
    }

    public float spacingY
    {
        get
        {
            return m_Spacing.y;
        }
        set
        {
            m_Spacing = new Vector2(m_Spacing.x, value);
        }
    }
}


