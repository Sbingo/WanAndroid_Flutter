import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/widget/loading_view.dart';
import 'package:wanandroid_flutter/widget/error_view.dart';
import 'package:wanandroid_flutter/widget/empty_view.dart';
import 'package:wanandroid_flutter/widget/refreshable_list.dart';
import 'package:wanandroid_flutter/widget/article_item_view.dart';
import 'package:wanandroid_flutter/utils/apis.dart';

class ArticleTabPage extends StatefulWidget {
  Future request;
  List data;

  ArticleTabPage(this.request, this.data);

  @override
  State<StatefulWidget> createState() => _ArticleTabState();
}

class _ArticleTabState extends State<ArticleTabPage> {
  bool isLoading = true;
  bool isEmpty = false;
  bool isError = false;
  String errorInfo = "";

  @override
  void initState() {
    super.initState();
    if (widget.request != null) {
      getData();
    } else if (widget.data != null && widget.data.length > 0) {
      isLoading = false;
      setState(() {});
    } else {
      isLoading = false;
      isError = true;
      errorInfo = '未传入请求或数据！';
      setState(() {});
    }
  }

  getData() {
    widget.request.then((result) {
      isLoading = false;
      isEmpty = result == null;
      widget.data = result;
      setState(() {});
    }).catchError((e) {
      isLoading = false;
      isError = true;
      setError(e);
      setState(() {});
    });
  }

  setError(e) {
    if (e is Exception) {
      errorInfo = e.toString();
    } else if (e is String) {
      errorInfo = e;
    }
  }

  retry() {
    if (widget.request != null) {
      setState(() {
        isLoading = true;
      });
      getData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return LoadingView();
    } else if (isError) {
      return ErrorView(
        error: errorInfo,
        retry: retry,
      );
    } else if (isEmpty) {
      return EmptyView(
        retry: retry,
      );
    }
    return DefaultTabController(
      length: widget.data.length,
      child: Column(
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              tabs: widget.data.map((item) {
                return Tab(
                  text: item['name'],
                );
              }).toList(),
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              labelStyle: TextStyle(fontSize: 20),
              indicatorColor: Colors.white,
            ),
          ),
          Expanded(
            child: TabBarView(
              children: widget.data.map(_buildPage).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(item) {
    return RefreshableList(
      [Apis.wxArticles(item['id'])],
      ['datas'],
      [''],
      _buildItem,
      initPageNo: 1,
    );
  }

  _buildItem(item) {
    return ArticleItemView(item);
  }
}
