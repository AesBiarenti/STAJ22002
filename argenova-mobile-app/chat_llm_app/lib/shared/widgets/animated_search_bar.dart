import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String? hintText;
  final bool initiallyExpanded;

  const AnimatedSearchBar({
    super.key,
    required this.onSearch,
    this.hintText,
    this.initiallyExpanded = false,
  });

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _widthAnimation = Tween<double>(begin: 40.0, end: 140.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    if (widget.initiallyExpanded) {
      _expandSearch();
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isExpanded) {
        _collapseSearch();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expandSearch() {
    if (_isExpanded) return;

    setState(() => _isExpanded = true);
    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  void _collapseSearch() {
    if (!_isExpanded) return;

    _focusNode.unfocus();
    _searchController.clear();
    widget.onSearch('');

    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() => _isExpanded = false);
      }
    });
  }

  void _onSearchChanged(String value) {
    widget.onSearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Arama butonu / Search bar container
              Flexible(
                child: Container(
                  width: _widthAnimation.value,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _isExpanded
                      ? Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _focusNode,
                                      onChanged: _onSearchChanged,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        height: 2.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: widget.hintText ?? 'Ara...',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 15,
                                          height: 1.2,
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        isDense: true,
                                      ),
                                      cursorColor: Colors.white,
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        _onSearchChanged('');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.clear,
                                          color: Colors.white.withOpacity(0.8),
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: _expandSearch,
                          child: const Center(
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                ),
              ),
              // Kapatma butonu (sadece genişletildiğinde görünür)
              if (_isExpanded) ...[
                const SizedBox(width: 6),
                AnimatedOpacity(
                  opacity: _opacityAnimation.value,
                  duration: const Duration(milliseconds: 150),
                  child: GestureDetector(
                    onTap: _collapseSearch,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
