import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OptionTile extends StatefulWidget {

  final String option;
  final String label;
  final Color optionColor;
  final String optionImageUrl;
  final String optionCaption;

  OptionTile({this.option, this.label, this.optionColor, this.optionImageUrl, this.optionCaption});

  @override
  _OptionTileState createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> {

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: widget.optionImageUrl == null ? EdgeInsets.symmetric(vertical: 10.0) : EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        children: [
          widget.optionImageUrl != null ? GestureDetector(
            // INFO : This onTap is used to overwrite parent widgets' onTap function
            onTap: () {},
            child: Container(
              child: CachedNetworkImage(
                imageUrl: widget.optionImageUrl,
                imageBuilder: (context, imageProvider) {
                  return Column(
                    children: [
                      Container(
                        child: Image(
                          image: imageProvider,
                        ),
                      ),
                      widget.optionCaption != null ? Center(
                        child: Container(
                          child: Text(widget.optionCaption,
                            style: TextStyle(color: Colors.black45), textAlign: TextAlign.center,
                          ),
                        ),
                      ) : Container(),
                    ],
                  );
                },
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, e) => Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  alignment: Alignment.topCenter,
                  child: Text("Error loading image", style: TextStyle(fontSize: 18),),
                ),
              ),
            ),
          ) : Container(),
          widget.optionImageUrl != null || widget.optionCaption != null ? SizedBox(height: 5,) : Container(),
          Align(
            alignment: Alignment.topLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: widget.optionColor,
                      border: Border.all(
                        color: Colors.black87,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Text(widget.label, style: TextStyle(fontSize: 18.0,),),
                  ),
                  SizedBox(width: 10,),
                  GestureDetector(
                    // INFO : This onTap is used to overwrite parent widgets' onTap function
                    onTap: () {},
                    child: Container(
                      child: Text(
                        widget.option,
                        style: TextStyle(fontSize: 19.0, color: Colors.black.withOpacity(0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
