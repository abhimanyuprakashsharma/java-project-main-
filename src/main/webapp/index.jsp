<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.shopsphere.model.User" %>
<%@ page import="com.shopsphere.model.Product" %>
<%@ page import="com.shopsphere.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<%
    User u = (User) session.getAttribute("loggedInUser");
    List<Product> featuredProducts;
    try {
        featuredProducts = new ProductDAO().search(null, 0, "newest", 1, 6);
    } catch (Exception e) {
        featuredProducts = java.util.Collections.emptyList();
    }
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Trendify — Curated Lifestyle & Modern Boutique</title>
    <meta name="description" content="Trendify — A luxury lifestyle boutique for curated fashion, bespoke living essentials, and elevated everyday craftsmanship.">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="announcement-bar">
    <span>COMPLIMENTARY WHITE-GLOVE DELIVERY ON ORDERS OVER ₹999 • THE ATELIER COLLECTION</span>
</div>
<header class="nav-header">
    <div class="container nav-inner">
        <nav class="nav-menu">
            <a class="nav-link active" href="${pageContext.request.contextPath}/">Shop</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/products">Collections</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/products?category=3">Fashion</a>
            <a class="nav-link" href="${pageContext.request.contextPath}/products?category=2">Books</a>
        </nav>
        <a class="brand-logo" href="${pageContext.request.contextPath}/">Trendify</a>
        <div>
            <a class="btn ghost" href="${pageContext.request.contextPath}/products">Search</a>
            <% if (u == null) { %>
                <a class="btn ghost" href="${pageContext.request.contextPath}/login">Account</a>
            <% } else if ("ADMIN".equalsIgnoreCase(u.getRole())) { %>
                <a class="btn ghost" href="${pageContext.request.contextPath}/admin/dashboard">Account</a>
            <% } else { %>
                <a class="btn ghost" href="${pageContext.request.contextPath}/profile">Account</a>
            <% } %>
            <a class="btn ghost" href="${pageContext.request.contextPath}/cart">Cart</a>
        </div>
    </div>
</header>

<section class="hero-wrapper" style="background-image: linear-gradient(90deg, rgba(28,24,21,0.74) 0%, rgba(28,24,21,0.42) 50%, rgba(28,24,21,0.72) 100%), url('https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=2200&q=88');">
    <div class="hero-grid">
        <div>
            <span class="badge-tag">THE BOUTIQUE EDIT • 2026</span>
            <h1 class="hero-title">Trendify</h1>
            <p class="hero-subtitle">Curated modern lifestyle. Elevated fashion. Thoughtful living. Discover timeless apparel, crafted essentials, and bespoke collections for the refined home.</p>
            <div class="hero-buttons">
                <a class="btn" href="${pageContext.request.contextPath}/products">Explore Collection</a>
                <a class="btn secondary" href="#new-arrivals">View New Arrivals</a>
            </div>
        </div>
    </div>
</section>

<!-- Boutique Trust & Values Bar -->
<section class="features-grid container" style="margin-top:-20px; position:relative; z-index:3; border-radius:14px; overflow:hidden;">
    <div class="feature-card">
        <h4>Complimentary Delivery</h4>
        <p>White-glove shipping on curated orders over ₹999.</p>
    </div>
    <div class="feature-card">
        <h4>Artisan Quality</h4>
        <p>Hand-picked materials and authentic craftsmanship.</p>
    </div>
    <div class="feature-card">
        <h4>Bespoke Concierge</h4>
        <p>Dedicated customer care for a seamless journey.</p>
    </div>
    <div class="feature-card">
        <h4>Effortless Returns</h4>
        <p>30-day hassle-free returns and exchanges.</p>
    </div>
</section>

<main>
<section class="section container">
    <div class="section-head">
        <div>
            <span class="eyebrow">CURATED COLLECTIONS</span>
            <h2>Find your next signature piece.</h2>
        </div>
        <span class="eyebrow">03 ATELIERS</span>
    </div>
    <div class="curated-grid">
        <a class="curated-card" href="${pageContext.request.contextPath}/products?category=1">
            <img src="https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=1200&q=85" alt="Living & Technology collection">
            <div class="curated-copy">
                <h3>Living & Tech</h3>
                <span>Explore collection →</span>
            </div>
        </a>
        <a class="curated-card" href="${pageContext.request.contextPath}/products?category=3">
            <img src="https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=1200&q=85" alt="High Fashion collection">
            <div class="curated-copy">
                <h3>Haute Fashion</h3>
                <span>Explore collection →</span>
            </div>
        </a>
        <a class="curated-card" href="${pageContext.request.contextPath}/products?category=2">
            <img src="https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=1200&q=85" alt="Editorial & Books collection">
            <div class="curated-copy">
                <h3>Books & Living</h3>
                <span>Explore collection →</span>
            </div>
        </a>
    </div>
</section>

<section id="new-arrivals" class="products-section container">
    <div class="section-head">
        <div>
            <span class="eyebrow">NEW ARRIVALS</span>
            <h2>Curated pieces for everyday luxury.</h2>
        </div>
        <a class="btn ghost" href="${pageContext.request.contextPath}/products">View all collections</a>
    </div>
    <div class="grid">
        <% if (featuredProducts != null && !featuredProducts.isEmpty()) {
            String[] productImages = {
                "https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=900&q=85",
                "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=85",
                "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=85",
                "https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=85",
                "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=85",
                "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=900&q=85"
            };
            int i = 0;
            for (Product p : featuredProducts) {
                String image = (p.getImageUrl() != null && !p.getImageUrl().trim().isEmpty()) ? p.getImageUrl() : productImages[i % productImages.length];
        %>
        <article class="product-card">
            <a class="product-image" href="${pageContext.request.contextPath}/product?id=<%= p.getProductId() %>">
                <img src="<%= image %>" alt="<%= p.getName() %>">
                <span class="product-tag"><%= p.getStock() > 0 ? "NEW" : "SOLD OUT" %></span>
            </a>
            <div class="product-body">
                <span class="chip"><%= p.getBrand() != null ? p.getBrand() : "Trendify Atelier" %></span>
                <a class="product-title" href="${pageContext.request.contextPath}/product?id=<%= p.getProductId() %>"><%= p.getName() %></a>
                <p class="muted"><%= p.getDescription() != null && p.getDescription().length() > 72 ? p.getDescription().substring(0,72) + "…" : (p.getDescription() == null ? "" : p.getDescription()) %></p>
                <div style="display:flex;justify-content:space-between;align-items:center;margin-top:6px;">
                    <span class="price">₹<%= String.format("%.2f", p.getPrice()) %></span>
                    <% if (p.getStock() > 0) { %>
                        <span class="chip success">In stock</span>
                    <% } else { %>
                        <span class="chip danger">Out of stock</span>
                    <% } %>
                </div>
                <div class="product-actions">
                    <% if (p.getStock() > 0) { %>
                    <form method="post" action="${pageContext.request.contextPath}/cart">
                        <input type="hidden" name="_csrf" value="${csrfToken}" />
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                        <input type="hidden" name="quantity" value="1">
                        <button type="submit">Add to bag</button>
                    </form>
                    <% } %>
                    <form method="post" action="${pageContext.request.contextPath}/wishlist">
                        <input type="hidden" name="_csrf" value="${csrfToken}" />
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                        <button class="btn ghost" type="submit" title="Add to wishlist">♡</button>
                    </form>
                </div>
            </div>
        </article>
        <% i++; } } else { %>
            <div class="card" style="grid-column:1/-1;text-align:center;">
                <h3>Discover our boutique catalog</h3>
                <p class="muted">Explore the complete Trendify collection.</p>
                <a class="btn" href="${pageContext.request.contextPath}/products" style="margin-top:18px;">Browse all pieces</a>
            </div>
        <% } %>
    </div>
</section>

<!-- Editorial Living Feature -->
<section class="editorial-feature" style="background-image: linear-gradient(90deg, rgba(28,24,21,0.8) 0%, rgba(28,24,21,0.3) 60%, rgba(28,24,21,0.76) 100%), url('https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?auto=format&fit=crop&w=2200&q=85');">
    <div class="container">
        <div class="feature-copy">
            <span class="eyebrow" style="color:#C5A880;">THE ATELIER EDIT</span>
            <h2>Crafted for purposeful living.</h2>
            <p>From refined wardrobe staples to artisanal accents for your sanctuary. Every piece in our boutique is chosen for timeless quality, conscious beauty, and everyday elegance.</p>
            <a class="btn secondary" href="${pageContext.request.contextPath}/products">Discover The Full Collection</a>
        </div>
    </div>
</section>
</main>

<footer class="main-footer">
    <div class="container">
        <div class="footer-grid">
            <div>
                <a class="brand-logo" href="${pageContext.request.contextPath}/">Trendify</a>
                <p class="muted" style="max-width:360px;margin-top:14px;color:#A89E92;">An elevated boutique shopping experience celebrating craftsmanship, modern fashion, and thoughtful living.</p>
            </div>
            <div>
                <h4 class="footer-title">Collections</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/products">All pieces</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=3">Fashion</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=1">Living & Tech</a></li>
                    <li><a href="${pageContext.request.contextPath}/products?category=2">Books & Editorial</a></li>
                </ul>
            </div>
            <div>
                <h4 class="footer-title">Account</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/profile">My Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">Order History</a></li>
                    <li><a href="${pageContext.request.contextPath}/wishlist">Saved Wishlist</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Shopping Bag</a></li>
                </ul>
            </div>
            <div>
                <h4 class="footer-title">Trendify</h4>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/login">Member Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register">Create Account</a></li>
                    <li><a href="${pageContext.request.contextPath}/syllabus">Advanced Java Syllabus</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <span>© 2026 Trendify Boutique Ltd. All rights reserved.</span>
            <span>Curated lifestyle, refined for everyday living.</span>
        </div>
    </div>
</footer>
<script src="${pageContext.request.contextPath}/assets/js/app.js"></script>
</body>
</html>