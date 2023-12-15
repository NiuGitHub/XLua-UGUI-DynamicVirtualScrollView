using System;
using UnityEditor;
using UnityEditor.UI;
using UnityEngine;
using UnityEngine.UI;

[CustomEditor(typeof(Lua_ScrollView))]
public class Lua_ScrollViewEditor : ScrollRectEditor
{
    SerializedProperty m_LayoutType;
    SerializedProperty itemPrefab;
    SerializedProperty perLineItemNum;
    SerializedProperty m_Spacing;
    SerializedProperty vertical;
    SerializedProperty horizontal;
    SerializedProperty contentProperty;
    protected override void OnEnable()
    {
        base.OnEnable();
        m_LayoutType = serializedObject.FindProperty("m_LayoutType");
        itemPrefab = serializedObject.FindProperty("itemPrefab");
        perLineItemNum = serializedObject.FindProperty("perLineItemNum");
        m_Spacing = serializedObject.FindProperty("m_Spacing");
        vertical = serializedObject.FindProperty("m_Vertical");
        horizontal = serializedObject.FindProperty("m_Horizontal");
        contentProperty = serializedObject.FindProperty("m_Content");
    }

    GUIStyle m_caption;
    GUIStyle caption
    {
        get
        {
            if (m_caption == null)
            {
                m_caption = new GUIStyle { richText = true, alignment = TextAnchor.MiddleCenter };
                m_caption.normal.textColor = Color.green;
            }
            return m_caption;
        }
    }

    GUIStyle m_TipsGUIStyle;

    GUIStyle tipsGUIStyle
    {
        get
        {
            if (m_TipsGUIStyle == null)
            {
                m_TipsGUIStyle = new GUIStyle { richText = false, alignment = TextAnchor.MiddleLeft };
                m_TipsGUIStyle.normal.textColor = Color.cyan;
            }
            return m_TipsGUIStyle;
        }
    }

    GUIStyle m_warningGUIStyle;

    GUIStyle warningGUIStyle
    {
        get
        {
            if (m_warningGUIStyle == null)
            {
                m_warningGUIStyle = new GUIStyle { richText = true, alignment = TextAnchor.MiddleCenter };
                m_warningGUIStyle.normal.textColor = Color.red;
            }
            return m_warningGUIStyle;
        }
    }
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUILayout.BeginVertical("box");
        EditorGUILayout.LabelField("<b>禁止修改Content的pivot\n为了方便计算默认pivot=(0,1)</b>", warningGUIStyle);
        EditorGUILayout.LabelField("<b>Additional configs</b>", caption);
        EditorGUILayout.Space(5);
        DrawConfigInfo();
        serializedObject.ApplyModifiedProperties();
        EditorGUILayout.EndVertical();

        EditorGUILayout.BeginVertical("box");
        EditorGUILayout.LabelField("<b>For original ScrollRect</b>", caption);
        EditorGUILayout.Space(5);
        base.OnInspectorGUI();
        EditorGUILayout.EndVertical();
        //resetContentPivot();
    }
    private void resetContentPivot()
    {
        if (contentProperty.objectReferenceValue != null)
        {
            RectTransform contentRectTransform = contentProperty.objectReferenceValue as RectTransform;
            if (contentRectTransform != null)
            {
                contentRectTransform.pivot = TopLeft;
                EditorUtility.SetDirty(contentRectTransform.gameObject);
            }
        }

    }

    protected virtual void DrawConfigInfo()
    {
        EditorGUILayout.LabelField("滑动类型=>通过这里控制", tipsGUIStyle);
        EditorGUILayout.PropertyField(m_LayoutType);//字段名称为Layout Type
        //layoutType.intValue = (int)(VirtualScrollView.eLayoutType)EditorGUILayout.EnumPopup("layoutType", (VirtualScrollView.eLayoutType)layoutType.intValue); //字段名称为layoutType
        EditorGUILayout.LabelField("Item预制体", tipsGUIStyle);
        EditorGUILayout.PropertyField(itemPrefab);
        EditorGUILayout.LabelField("Item每行最大显示数量", tipsGUIStyle);
        EditorGUILayout.PropertyField(perLineItemNum);
        EditorGUILayout.LabelField("X列间隔 Y行间隔", tipsGUIStyle);
        EditorGUILayout.PropertyField(m_Spacing);
        vertical.boolValue = m_LayoutType.intValue == (int)Lua_ScrollView.eLayoutType.Vertical;
        horizontal.boolValue = m_LayoutType.intValue == (int)Lua_ScrollView.eLayoutType.Horizontal;

    }





    static Vector2 TopLeft = new Vector2(0,1);

    const string bgPath = "UI/Skin/Background.psd";
    const string spritePath = "UI/Skin/UISprite.psd";
    const string maskPath = "UI/Skin/UIMask.psd";
    static Color panelColor = new Color(1f, 1f, 1f, 0.392f);
    static Color defaultSelectableColor = new Color(1f, 1f, 1f, 1f);
    static Vector2 thinElementSize = new Vector2(160f, 20f);



    [MenuItem("GameObject/UI/Lua_ScrollView", false, 90)]
    static public void AddScrollView(MenuCommand menuCommand)
    {
        InternalAddScrollView<Lua_ScrollView>(menuCommand);
    }
    protected static void InternalAddScrollView<T>(MenuCommand menuCommand) where T : Lua_ScrollView
    {
        GameObject root = CreateUIElementRoot(typeof(T).Name, new Vector2(200, 200));
        root.layer = LayerMask.NameToLayer("UI");
        Image rootImage = root.AddComponent<Image>();
        //rootImage.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>(bgPath);
        //rootImage.type = Image.Type.Sliced;
        rootImage.color = panelColor;

        GameObject parent = menuCommand.context as GameObject;
        if (parent != null)
        {
            root.transform.SetParent(parent.transform, false);
        }
        Selection.activeGameObject = root;

        GameObject viewport = CreateUIObject("Viewport", root, typeof(CanvasRenderer), typeof(RectMask2D));
        RectTransform viewportRect = viewport.GetComponent<RectTransform>();
        viewportRect.anchorMin = new Vector2(0, 0);
        viewportRect.anchorMax = new Vector2(1, 1);
        viewportRect.sizeDelta = Vector2.zero;
        viewportRect.pivot = new Vector2(0.5f, 0.5f);
        viewportRect.offsetMin = Vector2.zero;
        viewportRect.offsetMax = Vector2.zero;


        GameObject content = CreateUIObject("Content", viewport);
        RectTransform contentRect = content.GetComponent<RectTransform>();
        contentRect.anchorMin = new Vector2(0, 1);
        contentRect.anchorMax = new Vector2(0, 1);
        contentRect.sizeDelta = Vector2.zero;
        contentRect.pivot = new Vector2(0, 1);
        contentRect.offsetMin = Vector2.zero;
        contentRect.offsetMax = Vector2.zero;


        //GameObject hScrollbar = CreateScrollbar();
        //hScrollbar.name = "Scrollbar Horizontal";
        //hScrollbar.transform.SetParent(root.transform, false);
        //RectTransform hScrollbarRT = hScrollbar.GetComponent<RectTransform>();
        //hScrollbarRT.anchorMin = Vector2.zero;
        //hScrollbarRT.anchorMax = Vector2.right;
        //hScrollbarRT.pivot = Vector2.zero;
        //hScrollbarRT.sizeDelta = new Vector2(0, hScrollbarRT.sizeDelta.y);

        //GameObject vScrollbar = CreateScrollbar();
        //vScrollbar.name = "Scrollbar Vertical";
        //vScrollbar.transform.SetParent(root.transform, false);
        //vScrollbar.GetComponent<Scrollbar>().SetDirection(Scrollbar.Direction.BottomToTop, true);
        //RectTransform vScrollbarRT = vScrollbar.GetComponent<RectTransform>();
        //vScrollbarRT.anchorMin = Vector2.right;
        //vScrollbarRT.anchorMax = Vector2.one;
        //vScrollbarRT.pivot = Vector2.one;
        //vScrollbarRT.sizeDelta = new Vector2(vScrollbarRT.sizeDelta.x, 0);



        Lua_ScrollView scrollRect = root.AddComponent<T>();
        scrollRect.content = contentRect;
        scrollRect.viewport = viewportRect;
        //scrollRect.horizontalScrollbar = hScrollbar.GetComponent<Scrollbar>();
        //scrollRect.verticalScrollbar = vScrollbar.GetComponent<Scrollbar>();
        scrollRect.horizontalScrollbarVisibility = ScrollRect.ScrollbarVisibility.AutoHideAndExpandViewport;
        scrollRect.verticalScrollbarVisibility = ScrollRect.ScrollbarVisibility.AutoHideAndExpandViewport;
        //scrollRect.horizontalScrollbarSpacing = -3;
        //scrollRect.verticalScrollbarSpacing = -3;



    }



    static GameObject CreateScrollbar()
    {
        // Create GOs Hierarchy
        GameObject scrollbarRoot = CreateUIElementRoot("Scrollbar", thinElementSize);
        GameObject sliderArea = CreateUIObject("Sliding Area", scrollbarRoot);
        GameObject handle = CreateUIObject("Handle", sliderArea);

        Image bgImage = scrollbarRoot.AddComponent<Image>();
        bgImage.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>(bgPath);
        bgImage.type = Image.Type.Sliced;
        bgImage.color = defaultSelectableColor;

        Image handleImage = handle.AddComponent<Image>();
        handleImage.sprite = AssetDatabase.GetBuiltinExtraResource<Sprite>(spritePath);
        handleImage.type = Image.Type.Sliced;
        handleImage.color = defaultSelectableColor;

        RectTransform sliderAreaRect = sliderArea.GetComponent<RectTransform>();
        sliderAreaRect.sizeDelta = new Vector2(-20, -20);
        sliderAreaRect.anchorMin = Vector2.zero;
        sliderAreaRect.anchorMax = Vector2.one;

        RectTransform handleRect = handle.GetComponent<RectTransform>();
        handleRect.sizeDelta = new Vector2(20, 20);

        Scrollbar scrollbar = scrollbarRoot.AddComponent<Scrollbar>();
        scrollbar.handleRect = handleRect;
        scrollbar.targetGraphic = handleImage;
        SetDefaultColorTransitionValues(scrollbar);

        return scrollbarRoot;
    }

    static GameObject CreateUIElementRoot(string name, Vector2 size, params Type[] components)
    {
        GameObject child = new GameObject(name, components);
        RectTransform rectTransform = child.GetComponent<RectTransform>();
        if (child.GetComponent<RectTransform>() == null)
        {
            rectTransform = child.AddComponent<RectTransform>();
        }
        rectTransform.sizeDelta = size;
        return child;
    }

    static GameObject CreateUIObject(string name, GameObject parent, params Type[] components)
    {
        GameObject go = new GameObject(name, components);
        if (go.GetComponent<RectTransform>() == null)
        {
            go.AddComponent<RectTransform>();
        }
        SetParentAndAlign(go, parent);
        return go;
    }

    private static void SetParentAndAlign(GameObject child, GameObject parent)
    {
        if (parent == null)
            return;

        child.transform.SetParent(parent.transform, false);
        SetLayerRecursively(child, parent.layer);
    }

    static void SetLayerRecursively(GameObject go, int layer)
    {
        go.layer = layer;
        Transform t = go.transform;
        for (int i = 0; i < t.childCount; i++)
            SetLayerRecursively(t.GetChild(i).gameObject, layer);
    }

    static void SetDefaultColorTransitionValues(Selectable slider)
    {
        ColorBlock colors = slider.colors;
        colors.highlightedColor = new Color(0.882f, 0.882f, 0.882f);
        colors.pressedColor = new Color(0.698f, 0.698f, 0.698f);
        colors.disabledColor = new Color(0.521f, 0.521f, 0.521f);
    }
}
